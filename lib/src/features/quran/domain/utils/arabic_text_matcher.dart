import 'dart:math';

/// Result of matching a single word
enum WordMatchStatus { matched, mismatched, missing }

class WordMatchResult {
  final String expectedWord;
  final String? spokenWord;
  final WordMatchStatus status;

  const WordMatchResult({
    required this.expectedWord,
    this.spokenWord,
    required this.status,
  });
}

/// Utility class for normalizing Arabic text and matching spoken vs expected Quran text.
class ArabicTextMatcher {
  // ═══ Pre-compiled RegExp patterns — computed once at app start ═══

  /// Batch remove: Quranic annotation marks (0610-061A), stop marks (06D6-06ED),
  /// tashkeel/harakat (064B-065F), superscript alef (0670), tatweel (0640)
  static final RegExp _removableMarks = RegExp(
    '[\u0621\u0610-\u061A\u064B-\u065F\u0670\u0640\u06D6-\u06ED]',
  );

  /// Letter standardization map — applied after stripping marks
  static final Map<String, String> _letterMap = {
    '\u0671': '\u0627', // Alef Wasla → Alef (CRITICAL for Quran text!)
    '\u0624': '\u0648', // Waw Hamza Above → Waw
    '\u0629': '\u0647', // Ta Marbuta → Ha
    '\u064A': '\u0649', // Ya → Alif Maksura
    '\u0626': '\u0649', // Ya Hamza Above → Alif Maksura
    '\u0622': '\u0627', // Alif with Madda → Alif
    '\u0623': '\u0627', // Alif with Hamza Above → Alif
    '\u0625': '\u0627', // Alif with Hamza Below → Alif
    '\u0672': '\u0627', // Alef with Wavy Hamza Above → Alif
    '\u0673': '\u0627', // Alef with Wavy Hamza Below → Alif
    '\u0675': '\u0627', // High Hamza Alef → Alif
  };

  /// Pre-compiled regex for letter standardization (single pass)
  static final RegExp _letterStandardize = RegExp(
    '[${_letterMap.keys.join()}]',
  );

  /// Normalize Arabic text by stripping diacritics (harakat), tatweel,
  /// Quranic annotation marks, and standardizing letter forms.
  /// Optimized: uses pre-compiled RegExp for single-pass removal (~5-10x faster).
  static String normalizeArabic(String input) {
    return input
        // Convert superscript/small letters to standard letters before removing marks
        .replaceAll('\u0670', '\u0627') // Superscript Alif -> Alif
        .replaceAll('\u06E5', '\u0648') // Small Waw -> Waw
        .replaceAll('\u06E6', '\u0649') // Small Ya -> Alif Maksura
        // Single-pass removal of all diacritics, marks, and tatweel
        .replaceAll(_removableMarks, '')
        // Single-pass letter standardization
        .replaceAllMapped(
          _letterStandardize,
          (m) => _letterMap[m.group(0)!] ?? m.group(0)!,
        )
        // Compress any character repeated 3 or more times down to 2 times.
        // This handles "mad" (elongations) from STT engines (e.g. الضاااالين -> الضاالين)
        // keeping the word within the fuzzy matching distance threshold.
        .replaceAllMapped(RegExp(r'(.)\1{2,}'), (m) => m.group(1)! * 2)
        .trim();
  }

  /// Split text into words, normalizing whitespace.
  static List<String> _splitWords(String text) {
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  /// Match spoken words against expected words using LCS (Longest Common Subsequence)
  /// to handle insertions/deletions in speech output.
  ///
  /// Returns a [WordMatchResult] for each expected word.
  static List<WordMatchResult> matchWords(String spoken, String expected) {
    final normalizedSpoken = normalizeArabic(spoken);
    final normalizedExpected = normalizeArabic(expected);

    final spokenWords = _splitWords(normalizedSpoken);
    final expectedWords = _splitWords(normalizedExpected);

    if (expectedWords.isEmpty) return [];

    // Build LCS table
    final m = expectedWords.length;
    final n = spokenWords.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (wordsMatch(expectedWords[i - 1], spokenWords[j - 1])) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }

    // Backtrack to find which expected words were matched
    final Set<int> matchedExpectedIndices = {};
    int i = m, j = n;
    while (i > 0 && j > 0) {
      if (wordsMatch(expectedWords[i - 1], spokenWords[j - 1])) {
        matchedExpectedIndices.add(i - 1);
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    // Build results
    // Get original expected words (with diacritics) for display
    final originalExpectedWords = _splitWords(expected);
    final results = <WordMatchResult>[];

    for (int idx = 0; idx < originalExpectedWords.length; idx++) {
      if (matchedExpectedIndices.contains(idx)) {
        results.add(
          WordMatchResult(
            expectedWord: originalExpectedWords[idx],
            spokenWord: expectedWords[idx],
            status: WordMatchStatus.matched,
          ),
        );
      } else {
        results.add(
          WordMatchResult(
            expectedWord: originalExpectedWords[idx],
            status: WordMatchStatus.mismatched,
          ),
        );
      }
    }

    return results;
  }

  /// Huruf muqatta'ah: map single letter → set of possible spoken forms.
  /// STT engines output the spelled-out name (e.g. "قاف") instead of the letter "ق".
  static final Map<String, Set<String>> _muqattaahSpokenForms = {
    'ق': {'قاف', 'قوف', 'كاف', 'كوف'},
    'ن': {'نون'},
    'ص': {'صاد', 'صواد'},
    'ط': {'طا', 'طاء'},
    'ه': {'ها', 'هاء'},
    'ي': {'يا', 'ياء', 'يى'},
    'ع': {'عين'},
    'س': {'سين'},
    'ح': {'حا', 'حاء'},
    'ك': {'كاف', 'كف'},
    'ل': {'لام'},
    'م': {'ميم'},
    'ر': {'را', 'راء', 'ر'},
    'ا': {'الف', 'الاف'},
  };

  /// All valid spoken forms for any huruf muqatta'ah component
  static final Set<String> _allMuqattaahComponents = {
    ..._muqattaahSpokenForms.values.expand((e) => e),
  };

  /// Check if a word looks like a spelled-out muqatta'ah component (e.g. "الف")
  static bool isMuqattaahComponent(String word) {
    final wordCollapsed = word.replaceAll(RegExp(r'(.)\1+'), r'$1');
    if (_allMuqattaahComponents.contains(wordCollapsed) || _allMuqattaahComponents.contains(word)) {
      return true;
    }
    // Allow small typos
    for (final comp in _allMuqattaahComponents) {
      if (_levenshteinDistance(word, comp) <= 1 || _levenshteinDistance(wordCollapsed, comp) <= 1) {
        return true;
      }
    }
    return false;
  }

  /// Known multi-letter huruf muqatta'ah patterns (normalized)
  /// These appear as individual words at the start of certain surahs.
  /// Note: The superscript Alif (ٰ) normalizes to regular Alif (ا).
  static final Set<String> _muqattaahWords = {
    // Al-Baqarah, Al-Imran, Al-Ankabut, Ar-Rum, Luqman, As-Sajdah
    'الم', 
    
    // Al-A'raf
    'المص', 
    
    // Yunus, Hud, Yusuf, Ibrahim, Hijr
    'الر', 'الرا', 
    
    // Ar-Ra'd
    'المر', 'المرا', 
    
    // Maryam
    'كهىعص', 'كهاىاعص', 
    
    // Ta-Ha
    'طه', 'طاها', 
    
    // Ash-Shu'ara, Al-Qasas
    'طسم', 'طاسم', 
    
    // An-Naml
    'طس', 'طاس', 
    
    // Ya-Sin
    'ىس', 'ىاس', 
    
    // Sad
    'ص', 
    
    // Ghafir, Fussilat, Ash-Shura, Az-Zukhruf, Ad-Dukhan, Al-Jathiyah, Al-Ahqaf
    'حم', 'حام', 
    
    // Ash-Shura (part 2)
    'عسق', 
    
    // Qaf
    'ق', 
    
    // Al-Qalam
    'ن', 
  };

  /// Check if a normalized word is a huruf muqatta'ah pattern
  static bool isMuqattaahWord(String normalizedWord) {
    return _muqattaahWords.contains(normalizedWord);
  }

  /// Check if two normalized words match.
  /// Uses exact match after normalization per word.
  /// Could be extended with fuzzy matching (Levenshtein) if needed.
  static bool wordsMatch(String a, String b) {
    if (a == b) return true;

    // Arabic STT sometimes inserts or drops the definite article "ال"
    // on standalone words, especially names like "طالوت" -> "الطالوت".
    // Accept that small variant before broader fuzzy logic so we don't
    // get stuck early in the ayah when the recognizer adds the article.
    if (_matchesOptionalDefiniteArticle(a, b)) {
      return true;
    }

    // ═══ Multi-letter Huruf Muqatta'ah (الم, الر, etc.) ═══
    // STT spells these out (e.g. "الف لام ميم" or even "الف", "لام", "ر"). 
    // If the expected word is a known muqatta'ah word AND the spoken word
    // looks like a letter component, we accept it.
    if (isMuqattaahWord(a)) {
      final bCollapsed = b.replaceAll(RegExp(r'(.)\1+'), r'$1');
      if (_allMuqattaahComponents.contains(bCollapsed) || _allMuqattaahComponents.contains(b)) return true;
      for (final comp in _allMuqattaahComponents) {
        if (_levenshteinDistance(b, comp) <= 1 || _levenshteinDistance(bCollapsed, comp) <= 1) return true;
      }
    } else if (isMuqattaahWord(b)) {
      final aCollapsed = a.replaceAll(RegExp(r'(.)\1+'), r'$1');
      if (_allMuqattaahComponents.contains(aCollapsed) || _allMuqattaahComponents.contains(a)) return true;
      for (final comp in _allMuqattaahComponents) {
        if (_levenshteinDistance(a, comp) <= 1 || _levenshteinDistance(aCollapsed, comp) <= 1) return true;
      }
    }

    // ═══ Single-letter Huruf Muqatta'ah ═══
    // When expected word is a single letter (e.g. ق from Quran text),
    // the STT engine may output the spoken name (e.g. قاف).
    // Long mad readings produce elongated forms (e.g. قاااااف → قااف after
    // normalization). We collapse ALL consecutive duplicates to 1 before
    // comparing against the known spoken forms.
    if (a.length == 1 && _muqattaahSpokenForms.containsKey(a)) {
      final bCollapsed = b.replaceAll(RegExp(r'(.)\1+'), r'$1');
      if (bCollapsed == a) return true; // Direct letter match
      
      for (final form in _muqattaahSpokenForms[a]!) {
        // Exact match or fuzzy match (1 edit distance tolerance) against spoken forms
        if (_levenshteinDistance(b, form) <= 1 ||
            _levenshteinDistance(bCollapsed, form) <= 1) {
          return true;
        }
      }
    }
    if (b.length == 1 && _muqattaahSpokenForms.containsKey(b)) {
      final aCollapsed = a.replaceAll(RegExp(r'(.)\1+'), r'$1');
      if (aCollapsed == b) return true; // Direct letter match
      
      for (final form in _muqattaahSpokenForms[b]!) {
        // Exact match or fuzzy match (1 edit distance tolerance) against spoken forms
        if (_levenshteinDistance(a, form) <= 1 ||
            _levenshteinDistance(aCollapsed, form) <= 1) {
          return true;
        }
      }
    }

    final distance = _levenshteinDistance(a, b);
    if (distance == 0) return true;

    // Targeted Leniency: Arabic STT vs Quranic Rasm (Orthography) differences.
    // Quran often uses/omits specific weak letters (like Alif, Waw, Ya) differently
    // than modern standard Arabic STT outputs.
    const weakLetters = {'ا', 'و', 'ي', 'ى', 'ه'};
    
    if (distance == 1) {
      final lenDiff = (a.length - b.length).abs();
      
      // Case 1: Insertion/deletion of a weak letter (different lengths)
      // Matches: (الرحمان vs الرحمن), (مالك vs ملك)
      if (lenDiff == 1) {
        final longer = a.length > b.length ? a : b;
        final shorter = a.length > b.length ? b : a;

        int i = 0, j = 0;
        int diffCount = 0;
        bool allowedDiff = true;

        while (i < longer.length && j < shorter.length) {
          if (longer[i] == shorter[j]) {
            i++;
            j++;
          } else {
            diffCount++;
            if (!weakLetters.contains(longer[i])) {
              allowedDiff = false;
              break;
            }
            i++; // Skip the inserted weak char
          }
        }

        // If the difference is at the very end of the word
        if (i < longer.length && j == shorter.length && diffCount == 0) {
          if (!weakLetters.contains(longer[i])) {
            allowedDiff = false;
          }
        }

        if (allowedDiff) return true;
      }
      
      // Case 2: Substitution between two weak letters (same length)
      // Matches: (وحلت vs احلت) where STT hears Waw instead of Alif
      // Rejects: consonant substitutions like (الرحيم vs الرجيم)
      if (lenDiff == 0) {
        for (int k = 0; k < a.length; k++) {
          if (a[k] != b[k]) {
            if (weakLetters.contains(a[k]) && weakLetters.contains(b[k])) {
              return true;
            }
            break; // Only one diff at distance==1, and it's not between weak letters
          }
        }
      }
    }

    return false;
  }

  static bool _matchesOptionalDefiniteArticle(String a, String b) {
    if (a.length < 3 || b.length < 3) return false;

    if (a.startsWith('ال') && a.substring(2) == b) return true;
    if (b.startsWith('ال') && b.substring(2) == a) return true;

    return false;
  }

  /// Calculate Levenshtein distance between two strings.
  static int _levenshteinDistance(String s, String t) {
    final m = s.length;
    final n = t.length;

    if (m == 0) return n;
    if (n == 0) return m;

    final d = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1, // deletion
          d[i][j - 1] + 1, // insertion
          d[i - 1][j - 1] + cost, // substitution
        ].reduce(min);
      }
    }

    return d[m][n];
  }

  /// Calculate accuracy as percentage of matched words.
  static double calculateAccuracy(List<WordMatchResult> results) {
    if (results.isEmpty) return 0.0;
    final matched = results
        .where((r) => r.status == WordMatchStatus.matched)
        .length;
    return matched / results.length;
  }

  /// Check if the accuracy meets the threshold (default 75%).
  static bool isPass(double accuracy, {double threshold = 0.75}) {
    return accuracy >= threshold;
  }
}
