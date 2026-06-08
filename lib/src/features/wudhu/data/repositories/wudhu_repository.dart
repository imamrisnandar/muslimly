import 'package:injectable/injectable.dart';
import '../../domain/repositories/wudhu_repository.dart';
import '../models/wudhu_model.dart';

@LazySingleton(as: WudhuRepository)
class WudhuRepositoryImpl implements WudhuRepository {
  @override
  Future<List<WudhuModel>> getWudhuContent(String locale) async {
    if (locale == 'id') {
      return _wudhuContentId;
    } else {
      return _wudhuContentEn;
    }
  }

  static const List<WudhuModel> _wudhuContentId = [
    WudhuModel(
      id: 'wudhu_1',
      order: 1,
      title: 'Kedudukan Wudhu dalam Shalat',
      description:
          'Penjelasan mengenai pentingnya wudhu sebagai syarat sah shalat.',
      contentMarkdown: r'''
# Kedudukan Wudhu dalam Shalat

Wudhu merupakan suatu hal yang tiada asing bagi setiap muslim, sejak kecil ia telah mengetahuinya bahkan telah mengamalkannya. Akan tetapi apakah wudhu yang telah kita lakukan selama bertahun-tahun atau bahkan telah puluhan tahun itu telah benar sesuai dengan apa yang diajarkan Nabi kita Muhammad shallallahu ‘alaihi was sallam? Karena suatu hal yang telah menjadi konsekuensi dari dua kalimat syahadat bahwa ibadah harus ikhlas mengharapkan ridha Allah dan sesuai sunnah Nabi shallallahu ‘alaihi was sallam.

Demikian juga teks masyhur bagi kita bahwa **wudhu merupakan syarat sah shalat**, yang mana jika syarat tidak terpenuhi maka tidak akan teranggap/terlaksana apa yang kita inginkan dari syarat tersebut.

### Dalil Hadits
> « لاَ تُقْبَلُ صَلاَةُ مَنْ أَحْدَثَ حَتَّى يَتَوَضَّأَ »
>
> *"Tidak diterima shalat orang yang berhadats sampai ia berwudhu."* (HR. Bukhari & Muslim)

### Dalil Al-Qur'an
> يَا أَيُّهَا الَّذِينَ آَمَنُوا إِذَا قُمْتُمْ إِلَى الصَّلَاةِ فَاغْسِلُوا وُجُوهَكُمْ وَأَيْدِيَكُمْ إِلَى الْمَرَافِقِ وَامْسَحُوا بِرُءُوسِكُمْ وَأَرْجُلَكُمْ إِلَى الْكَعْبَيْنِ
>
> *"Hai orang-orang yang beriman, apabila kamu hendak mengerjakan shalat, maka basuhlah mukamu dan tanganmu sampai dengan siku, dan sapulah kepalamu dan (basuh) kakimu sampai dengan kedua mata kaki".* (QS. Al-Maidah [5]: 6)

Maka marilah duduk bersama kami barang sejenak untuk mempelajari sifat/tata cara wudhu Nabi shallallahu ‘alaihi was sallam.
''',
    ),
    WudhuModel(
      id: 'wudhu_2',
      order: 2,
      title: 'Pengertian Wudhu',
      description: 'Definisi wudhu secara bahasa dan istilah syari\'at.',
      contentMarkdown: r'''
# Pengertian Wudhu

*   **Secara Bahasa**: Berarti *husnu* (keindahan) dan *nadhofah* (kebersihan). Wudhu untuk sholat dikatakan sebagai wudhu karena ia membersihkan anggota wudhu dan memperindahnya.
*   **Secara Istilah Syari’at**: Peribadatan kepada Allah ‘azza wa jalla dengan mencuci **empat anggota wudhu** dengan tata cara tertentu.
''',
    ),
    WudhuModel(
      id: 'wudhu_3',
      order: 3,
      title: 'Tata Cara Wudhu secara Global',
      description: 'Ringkasan tata cara wudhu berdasarkan hadits Nabi SAW.',
      contentMarkdown: r'''
# Tata Cara Wudhu secara Global

Adapun tata cara wudhu secara ringkas berdasarkan hadits Nabi shallallahu ‘alaihi was sallam dari **Humran** (budak sahabat Utsman bin Affan *radhiyallahu ‘anhu*):

> عَنْ حُمْرَانَ مَوْلَى عُثْمَانَ بْنِ عَفَّانَ أَنَّهُ رَأَى عُثْمَانَ دَعَا بِوَضُوءٍ ، فَأَفْرَغَ عَلَى يَدَيْهِ مِنْ إِنَائِهِ ، فَغَسَلَهُمَا ثَلاَثَ مَرَّاتٍ ، ثُمَّ أَدْخَلَ يَمِينَهُ فِى الْوَضُوءِ ، ثُمَّ تَمَضْمَضَ ، وَاسْتَنْشَقَ ، وَاسْتَنْثَرَ ، ثُمَّ غَسَلَ وَجْهَهُ ثَلاَثًا وَيَدَيْهِ إِلَى الْمِرْفَقَيْنِ ثَلاَثًا ، ثُمَّ مَسَحَ بِرَأْسِهِ ، ثُمَّ غَسَلَ كُلَّ رِجْلٍ ثَلاَثًا ، ثُمَّ قَالَ رَأَيْتُ النَّبِىَّ – صلى الله عليه وسلم – يَتَوَضَّأُ نَحْوَ وُضُوئِى هَذَا وَقَالَ « مَنْ تَوَضَّأَ نَحْوَ وُضُوئِى هَذَا ثُمَّ صَلَّى رَكْعَتَيْنِ ، لاَ يُحَدِّثُ فِيهِمَا نَفْسَهُ ، غَفَرَ اللَّهُ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ

### Terjemahan
Dari Humran -bekas budak Utsman bin Affan–, suatu ketika ‘Utsman memintanya untuk membawakan air wudhu (dengan wadah), kemudian ia tuangkan air dari wadah tersebut ke kedua tangannya. Maka ia membasuh kedua tangannya sebanyak tiga kali, lalu ia memasukkan tangan kanannya ke dalam air wudhu kemudian berkumur-kumur, lalu beristinsyaq dan beristintsar. Lalu beliau membasuh wajahnya sebanyak tiga kali, (kemudian) membasuh kedua tangannya sampai siku sebanyak tiga kali kemudian menyapu kepalanya (sekali saja) kemudian membasuh kedua kakinya sebanyak tiga kali, kemudian beliau mengatakan:
*"Aku melihat Nabi shallallahu ‘alaihi was sallam berwudhu dengan wudhu yang semisal ini dan beliau shallallahu ‘alaihi was sallam mengatakan, “Barangsiapa yang berwudhu dengan wudhu semisal ini kemudian sholat 2 roka’at (dengan khusyuk) dan ia tidak berbicara di antara wudhu dan sholatnya, maka Allah akan ampuni dosa-dosanya yang telah lalu."*

### Ringkasan Langkah
1.  Berniat wudhu (dalam hati).
2.  Mengucapkan basmalah.
3.  Membasuh dua telapak tangan (3x).
4.  Mengambil air dengan tangan kanan, memasukkannya ke mulut dan hidung untuk berkumur-kumur dan istinsyaq. Kemudian beristintsar dengan tangan kiri (3x).
5.  Membasuh seluruh wajah dan menyela-nyelai jenggot (3x).
6.  Membasuh tangan kanan hingga siku bersamaan dengan menyela-nyelai jemari (3x), dilanjutkan yang kiri.
7.  Menyapu seluruh kepala dari depan ke belakang lalu kembali ke depan (1x), dilanjutkan menyapu telinga (1x).
8.  Membasuh kaki kanan hingga mata kaki bersamaan dengan menyela-nyelai jemari (3x), dilanjutkan kaki kiri.
''',
    ),
    WudhuModel(
      id: 'wudhu_4',
      order: 4,
      title: 'Syarat-Syarat Wudhu',
      description: 'Tujuh syarat sah wudhu yang harus dipenuhi.',
      contentMarkdown: r'''
# Syarat-Syarat Wudhu

Syaikh Dr. Sholeh bin Fauzan bin Abdullah Al Fauzan menyebutkan syarat wudhu ada tujuh:

1.  **Islam**.
2.  **Berakal**.
3.  **Tamyiz** (Anak yang sudah mengerti).
4.  **Berniat** (Letak niat dalam hati ketika hendak melakukan ibadah).
5.  **Air Bersih** (Tahoour, dan bukan air yang diperoleh dengan cara haram).
6.  **Istinja’ & Istijmar** lebih dulu (Jika ada hadats sebelumnya).
7.  **Tidak ada penghalang** air sampai ke kulit.
''',
    ),
    WudhuModel(
      id: 'wudhu_5',
      order: 5,
      title: 'Wajib Wudhu (Rukun)',
      description: 'Hal-hal yang wajib dilakukan saat berwudhu.',
      contentMarkdown: r'''
# Wajib Wudhu (Rukun)

### a. Membaca Bismillah
> « لاَ صَلاَةَ لِمَنْ لاَ وُضُوءَ لَهُ وَلاَ وُضُوءَ لِمَنْ لَمْ يَذْكُرِ اسْمَ اللَّهِ تَعَالَى عَلَيْهِ »
>
> *"Tidak ada sholat bagi orang yang tidak berwudhu, dan tidak ada wudhu bagi orang yang tidak menyebut nama Allah Ta’ala (bismillah) ketika hendak berwudhu."*

### b. Membasuh Wajah (Berkumur, Istinsyaq, Istintsar)
Para ulama mengatakan batasan wajah adalah dari awal tempat tumbuh rambut (atas) sampai bawah jenggot (bawah), dan antar telinga (kanan-kiri).

*   **Berkumur**:
    > « إِذَا تَوَضَّأْتَ فَمَضْمِضْ »
    >
    > *"Jika engkau hendak wudhu, maka berkumur-kumurlah."*
*   **Istinsyaq & Istintsar**:
    > « إِذَا تَوَضَّأَ أَحَدُكُمْ فَلْيَسْتَنْشِقْ بِمَنْخِرَيْهِ مِنَ الْمَاءِ ثُمَّ لْيَنْتَثِرْ »
    >
    > *"Jika salah seorang dari kalian hendak berwudhu maka beristinsyaqlah di hidungnya dengan air kemudian beristintsarlah."*

### c. Menyela-nyelai Jenggot
> كَانَ إِذَا تَوَضَّأَ أَخَذَ كَفًّا مِنْ مَاءٍ فَأَدْخَلَهُ تَحْتَ حَنَكِهِ فَخَلَّلَ بِهِ لِحْيَتَهُ وَقَالَ « هَكَذَا أَمَرَنِى رَبِّى عَزَّ وَجَلَّ »
>
> *"Merupakan kebiasaan (Nabi ﷺ) jika beliau akan berwudhu, beliau mengambil segenggaman air kemudian beliau basuhkan (ke wajahnya) sampai ke tenggorokannya kemudian beliau menyela-nyelai jenggotnya”. Kemudian beliau mengatakan, “Demikianlah cara berwudhu yang diperintahkan Robbku kepadaku."* (HR. Abu Dawud)

### d. Membasuh Kedua Tangan Sampai Siku
> « ثُمَّ غَسَلَ يَدَهُ الْيُمْنَى إِلَى الْمَرْفِقِ ثَلاَثًا ، ثُمَّ غَسَلَ يَدَهُ الْيُسْرَى إِلَى الْمَرْفِقِ ثَلاَثًا »
>
> *"Kemudian beliau membasuh tangannya yang kanan sampai siku sebanyak tiga kali, kemudian membasuh tangannya yang kiri sampai siku sebanyak tiga kali."*

### e. Menyapu Kepala & Telinga
Hukum menyapu kepala adalah wajib.
> « ثُمَّ مَسَحَ رَأْسَهُ بِيَدَيْهِ ، فَأَقْبَلَ بِهِمَا وَأَدْبَرَ ، بَدَأَ بِمُقَدَّمِ رَأْسِهِ ، حَتَّى ذَهَبَ بِهِمَا إِلَى قَفَاهُ ، ثُمَّ رَدَّهُمَا إِلَى الْمَكَانِ الَّذِى بَدَأَ مِنْهُ »
>
> *"Kemudian beliau mengusap kepala dengan tangannya, menyapunya ke depan dan ke belakang. Beliau memulainya dari bagian depan kepalanya ditarik ke belakang sampai ke tengkuk kemudian mengembalikannya lagi ke bagian depan kepalanya."*

Tentang telinga:
> « الأُذُنَانِ مِنَ الرَّأْسِ »
>
> *"Kedua telinga merupakan bagian dari kepala."*

> « ثُمَّ مَسَحَ بِرَأْسِهِ وَأُذُنَيْهِ بَاطِنِهِمَا بِالسَّبَّاحَتَيْنِ وَظَاهِرِهِمَا بِإِبْهَامَيْهِ »
>
> *"Kemudian beliau menyapu kedua telinga sisi dalamnya dengan dua telunjuknya dan sisi luarnya dengan kedua jempolnya."*

### f. Membasuh Kaki Hingga Mata Kaki
Membasuh kedua mata kaki hukumnya wajib.
> « ثُمَّ غَسَلَ رِجْلَيْهِ إِلَى الْكَعْبَيْنِ »
>
> *"Kemudian beliau membasuh kedua kakinya hingga dua mata kaki."*

Menyela jari kaki:
> « إِذَا تَوَضَّأَ دَلَكَ أَصَابِعَ رِجْلَيْهِ بِخِنْصَرِهِ »
>
> *"Jika beliau shallallahu ‘alaihi was sallam berwudhu, beliau menggosok jari-jari kedua kakinya dengan dengan jari kelingkingnya."*

### g. Muwalah (Berturut-turut)
Membasuh anggota wudhu selanjutnya sebelum anggota sebelumnya kering.
Diriwayatkan dari Umar bin Khattab:
> أَنَّ رَجُلاً تَوَضَّأَ فَتَرَكَ مَوْضِعَ ظُفُرٍ عَلَى قَدَمِهِ فَأَبْصَرَهُ النَّبِىُّ -صلى الله عليه وسلم- فَقَالَ « ارْجِعْ فَأَحْسِنْ وُضُوءَكَ ». فَرَجَعَ ثُمَّ صَلَّى
>
> *"Bahwasanya ada seorang laki-laki berwudhu dan meninggalkan bagian yang belum dibasuh sebesar kuku pada kakinya. Ketika Nabi shallallahu ‘alaihi was sallam melihatnya maka Nabi shallallahu ‘alaihi was sallam mengatakan, “Kembalilah, perbaguslah wudhumu”."*
''',
    ),
    WudhuModel(
      id: 'wudhu_6',
      order: 6,
      title: 'Sunnah Wudhu',
      description: 'Amalan sunnah yang menyempurnakan wudhu.',
      contentMarkdown: r'''
# Sunnah Wudhu

### a. Bersiwak
> « لَوْلاَ أَنْ أَشُقَّ عَلَى أُمَّتِى لأَمَرْتُهُمْ بِالسِّوَاكِ عِنْدَ كُلِّ صَلاَةٍ »
>
> *"Seandainya jika tidak memberatkan ummatku, niscaya aku perintahkan mereka untuk bersiwak pada setiap hendak berwudhu."*

### b. Mencuci Kedua Tangan (3x) di Awal
> «وَإِذَا اسْتَيْقَظَ أَحَدُكُمْ مِنْ نَوْمِهِ فَلْيَغْسِلْ يَدَهُ قَبْلَ أَنْ يُدْخِلَهَا فِى وَضُوئِهِ ، فَإِنَّ أَحَدَكُمْ لاَ يَدْرِى أَيْنَ بَاتَتْ يَدُهُ »
>
> *"Jika salah seorang dari kalian bangun dari tidurnya maka hendaklah ia mencuci tangannya sebelum ia memasukkan tangannya ke air wudhu, karena ia tidak tahu di mana tangannya bermalam."*

### c. Bersungguh-sungguh dalam Istinsyaq
> « بَالِغْ فِى الاِسْتِنْشَاقِ إِلاَّ أَنْ تَكُونَ صَائِمًا »
>
> *"Bersungguh-sungguhlah dalam beristinsyaq kecuali jika kalian sedang berpuasa."*

### d. Mendahulukan Kanan (Tayamun)
> « كَانَ رَسُولُ اللَّهِ -صلى الله عليه وسلم- لَيُحِبُّ التَّيَمُّنَ فِى طُهُورِهِ إِذَا تَطَهَّرَ »
>
> *"Adalah kebiasaan Nabi shollallahu ‘alaihi was sallam sangat menyukai mendahulukan kanan dalam thoharoh (berwudhu)."*

### e. Membasuh 2x atau 3x
> أَنَّ النَّبِىَّ – صلى الله عليه وسلم – تَوَضَّأَ مَرَّتَيْنِ مَرَّتَيْنِ
>
> *"Sesungguhnya Nabi shallallahu ‘alaihi was sallam berwudhu dua kali-dua kali."*

### f. Tertib (Sesuai Urutan)
Dalil hadits Al Miqdam bin Ma’dikarib:
> *"Rosulullah shallallahu ‘alaihi was sallam melakukan wudhu dengan membasuh tangannya tiga kali kemudian berkumur-kumur dan istinsyaq tiga kali, kemudian membasuh wajahnya tiga kali, kemudian membasuh kakinya tiga kali, kemudian menyapu kepalanya dan telinga bagian luar maupun dalam."*

### g. Berdoa Setelah Wudhu
> « مَا مِنْكُمْ مِنْ أَحَدٍ يَتَوَضَّأُ فَيُبْلِغُ – أَوْ فَيُسْبِغُ – الْوُضُوءَ ثُمَّ يَقُولُ أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَنَّ مُحَمَّدًا عَبْدُ اللَّهِ وَرَسُولُهُ إِلاَّ فُتِحَتْ لَهُ أَبْوَابُ الْجَنَّةِ الثَّمَانِيَةُ يَدْخُلُ مِنْ أَيِّهَا شَاءَ »
>
> *"Tidaklah salah seorang dari kalian berwudhu dan ia menyempurnakan wudhunya kemudian membaca, “Aku bersaksi bahwa tidak ada sesembahan yang berhak disembah kecuali Allah, dan Nabi Muhammad adalah utusan Allah” melainkan akan dibukakan baginya pintu-pintu surga yang jumlahnya delapan, dan dia bisa masuk dari pintu mana saja ia mau."*

Tambahan riwayat Tirmidzi:
> اللَّهُمَّ اجْعَلْنِى مِنَ التَّوَّابِينَ وَاجْعَلْنِى مِنَ الْمُتَطَهِّرِينَ
>
> *"Ya Allah jadikanlah aku termasuk orang-orang yang bertaubat dan jadikanlah aku termsuk orang-orang yang selalu mensucikan diri."*

### h. Sholat Dua Rakaat Setelah Wudhu
> « مَنْ تَوَضَّأَ نَحْوَ وُضُوئِى هَذَا ثُمَّ صَلَّى رَكْعَتَيْنِ ، لاَ يُحَدِّثُ فِيهِمَا نَفْسَهُ ، غَفَرَ اللَّهُ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ »
>
> *"Barangsiapa berwudhu sebagaimana wudhuku ini, kemudian sholat 2 raka’at (dengan khusyuk) setelahnya dan ia tidak berbicara di antara keduanya, maka akan diampuni seluruh dosanya yang telah lalu."*
''',
    ),
  ];

  static const List<WudhuModel> _wudhuContentEn = [
    WudhuModel(
      id: 'wudhu_1',
      order: 1,
      title: 'Position of Wudhu in Prayer',
      description:
          'Understanding the importance of wudhu as a prerequisite for prayer.',
      contentMarkdown: r'''
# Position of Wudhu in Prayer

Wudhu is something familiar to every Muslim; known and practiced since childhood. However, is the wudhu we have performed for years aligned with what was taught by our Prophet Muhammad (peace be upon him)? A consequence of the testimony of faith is that worship must be done sincerely for Allah and in accordance with the Sunnah of the Prophet.

It is well known that **wudhu is a condition for the validity of prayer**. If a condition is not met, the act dependent on it is not considered valid.

### Hadith Evidence
> « لاَ تُقْبَلُ صَلاَةُ مَنْ أَحْدَثَ حَتَّى يَتَوَضَّأَ »
>
> *"The prayer of a person who does hadath (passes impurity) is not accepted until he performs wudhu."* (Narrated by Bukhari & Muslim)

### Quranic Evidence
> يَا أَيُّهَا الَّذِينَ آَمَنُوا إِذَا قُمْتُمْ إِلَى الصَّلَاةِ فَاغْسِلُوا وُجُوهَكُمْ وَأَيْدِيَكُمْ إِلَى الْمَرَافِقِ وَامْسَحُوا بِرُءُوسِكُمْ وَأَرْجُلَكُمْ إِلَى الْكَعْبَيْنِ
>
> *"O you who have believed, when you rise to [perform] prayer, wash your faces and your forearms to the elbows and wipe over your heads and wash your feet to the ankles."* (QS. Al-Maidah [5]: 6)

Let us take a moment to study the method of wudhu of the Prophet (peace be upon him).
''',
    ),
    WudhuModel(
      id: 'wudhu_2',
      order: 2,
      title: 'Definition of Wudhu',
      description: 'Linguistic and Sharia definition of wudhu.',
      contentMarkdown: r'''
# Definition of Wudhu

*   **Linguistically**: Means *husnu* (beauty) and *nadhofah* (cleanliness). Wudhu for prayer is named so because it cleanses and beautifies the limbs.
*   **According to Sharia**: Worshiping Allah The Almighty by washing **four specific limbs** in a specific manner.
''',
    ),
    WudhuModel(
      id: 'wudhu_3',
      order: 3,
      title: 'Global Wudhu Procedure',
      description: 'Summary of wudhu steps based on Hadith.',
      contentMarkdown: r'''
# Global Wudhu Procedure

The summary of the wudhu procedure is based on the hadith of **Humran** (the freed slave of Uthman bin Affan *radhiyallahu ‘anhu*):

> عَنْ حُمْرَانَ مَوْلَى عُثْمَانَ بْنِ عَفَّانَ أَنَّهُ رَأَى عُثْمَانَ دَعَا بِوَضُوءٍ ، فَأَفْرَغَ عَلَى يَدَيْهِ مِنْ إِنَائِهِ ، فَغَسَلَهُمَا ثَلاَثَ مَرَّاتٍ ، ثُمَّ أَدْخَلَ يَمِينَهُ فِى الْوَضُوءِ ، ثُمَّ تَمَضْمَضَ ، وَاسْتَنْشَقَ ، وَاسْتَنْثَرَ ، ثُمَّ غَسَلَ وَجْهَهُ ثَلاَثًا وَيَدَيْهِ إِلَى الْمِرْفَقَيْنِ ثَلاَثًا ، ثُمَّ مَسَحَ بِرَأْسِهِ ، ثُمَّ غَسَلَ كُلَّ رِجْلٍ ثَلاَثًا ، ثُمَّ قَالَ رَأَيْتُ النَّبِىَّ – صلى الله عليه وسلم – يَتَوَضَّأُ نَحْوَ وُضُوئِى هَذَا وَقَالَ « مَنْ تَوَضَّأَ نَحْوَ وُضُوئِى هَذَا ثُمَّ صَلَّى رَكْعَتَيْنِ ، لاَ يُحَدِّثُ فِيهِمَا نَفْسَهُ ، غَفَرَ اللَّهُ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ

### Translation
From Humran, Uthman called for water to perform wudhu. He poured water from the vessel onto his hands and washed them three times. Then he put his right hand in the water (to scoop it) and rinsed his mouth (Madmadah) and sniffed water into his nose (Istinshaq) and blew it out (Istinthar). Then he washed his face three times, and his hands up to the elbows three times. Then he wiped his head (once), and washed his feet three times. Then he said:
*"I saw the Prophet (peace be upon him) creating wudhu similar to my wudhu here, and he said: 'Whoever performs wudhu like this wudhu of mine, then prays two dakahs without talking to himself (focusing solely on prayer), his past sins will be forgiven.'"*

### Summary of Steps
1.  Intention (Niyyah) in the heart.
2.  Saying "Bismillah".
3.  Washing both palms (3x).
4.  Taking water with the right hand, putting it into the mouth and nose to rinse and sniff. Then blowing it out with the left hand (3x).
5.  Washing the entire face and running fingers through the beard (3x).
6.  Washing the right arm up to the elbow while running fingers between fingers (3x), then the left.
7.  Wiping the entire head from front to back and returning to the front (1x), followed by the ears (1x).
8.  Washing the right foot up to the ankle while cleaning between the toes (3x), then the left.
''',
    ),
    WudhuModel(
      id: 'wudhu_4',
      order: 4,
      title: 'Conditions of Wudhu',
      description: 'Seven conditions for the validity of wudhu.',
      contentMarkdown: r'''
# Conditions of Wudhu

Sheikh Dr. Sholeh bin Fauzan bin Abdullah Al Fauzan mentioned seven conditions of wudhu:

1.  **Islam** (Being a Muslim).
2.  **Sanity** (Being of sound mind).
3.  **Tamyiz** (A child who has reached the age of discernment).
4.  **Niyyah** (Intention in the heart before performing the act).
5.  **Pure Water** (Thahur - clean and purifying water, not obtained unlawfully).
6.  **Istinja’ & Istijmar first** (Cleaning oneself causing water to contact skin directly if there was impurity).
7.  **Removal of barriers** preventing water from reaching the skin (e.g., paint, wax).
''',
    ),
    WudhuModel(
      id: 'wudhu_5',
      order: 5,
      title: 'Obligations of Wudhu (Rukun)',
      description: 'Mandatory actions during wudhu.',
      contentMarkdown: r'''
# Obligations of Wudhu (Rukun)

### a. Saying Bismillah
> « لاَ صَلاَةَ لِمَنْ لاَ وُضُوءَ لَهُ وَلاَ وُضُوءَ لِمَنْ لَمْ يَذْكُرِ اسْمَ اللَّهِ تَعَالَى عَلَيْهِ »
>
> *"There is no prayer for the one who does not have wudhu, and there is no wudhu for the one who does not mention the name of Allah (Bismillah) upon it."*

### b. Washing the Face (Rinsing Mouth, Nose)
Scholars define the face as from the hairline to the chin/beard (vertically) and from ear to ear (horizontally).

*   **Rinsing Mouth (Madmadah)**:
    > « إِذَا تَوَضَّأْتَ فَمَضْمِضْ »
    >
    > *"When you perform wudhu, rinse your mouth."*
*   **Sniffing Water (Istinshaq & Istinthar)**:
    > « إِذَا تَوَضَّأَ أَحَدُكُمْ فَلْيَسْتَنْشِقْ بِمَنْخِرَيْهِ مِنَ الْمَاءِ ثُمَّ لْيَنْتَثِرْ »
    >
    > *"When one of you performs wudhu, let him sniff water into his nose and then blow it out."*

### c. Running Fingers through Beard (Takhleel)
> كَانَ إِذَا تَوَضَّأَ أَخَذَ كَفًّا مِنْ مَاءٍ فَأَدْخَلَهُ تَحْتَ حَنَكِهِ فَخَلَّلَ بِهِ لِحْيَتَهُ وَقَالَ « هَكَذَا أَمَرَنِى رَبِّى عَزَّ وَجَلَّ »
>
> *"When the Prophet (peace be upon him) performed wudhu, he took a handful of water and put it under his chin and ran his fingers through his beard, saying: 'This is what my Lord has commanded me.'"* (Narrated by Abu Dawud)

### d. Washing Hands to Elbows
> « ثُمَّ غَسَلَ يَدَهُ الْيُمْنَى إِلَى الْمَرْفِقِ ثَلاَثًا ، ثُمَّ غَسَلَ يَدَهُ الْيُسْرَى إِلَى الْمَرْفِقِ ثَلاَثًا »
>
> *"Then he washed his right hand up to the elbow three times, then washed his left hand up to the elbow three times."*

### e. Wiping Head & Ears
Wiping the head is obligatory.
> « ثُمَّ مَسَحَ رَأْسَهُ بِيَدَيْهِ ، فَأَقْبَلَ بِهِمَا وَأَدْبَرَ ، بَدَأَ بِمُقَدَّمِ رَأْسِهِ ، حَتَّى ذَهَبَ بِهِمَا إِلَى قَفَاهُ ، ثُمَّ رَدَّهُمَا إِلَى الْمَكَانِ الَّذِى بَدَأَ مِنْهُ »
>
> *"Then he wiped his head with his hands, moving them forward and backward. He began with the front of his head and went to the back of his neck, then returned them to the place where he started."*

Regarding ears:
> « الأُذُنَانِ مِنَ الرَّأْسِ »
>
> *"The ears are part of the head."*

> « ثُمَّ مَسَحَ بِرَأْسِهِ وَأُذُنَيْهِ بَاطِنِهِمَا بِالسَّبَّاحَتَيْنِ وَظَاهِرِهِمَا بِإِبْهَامَيْهِ »
>
> *"Then he wiped his head and his ears, the inside with his index fingers and the outside with his thumbs."*

### f. Washing Feet to Ankles
Washing both ankles is obligatory.
> « ثُمَّ غَسَلَ رِجْلَيْهِ إِلَى الْكَعْبَيْنِ »
>
> *"Then he washed his feet up to the ankles."*

Cleaning between toes:
> « إِذَا تَوَضَّأَ دَلَكَ أَصَابِعَ رِجْلَيْهِ بِخِنْصَرِهِ »
>
> *"When he performed wudhu, he rubbed his toes with his little finger."*

### g. Muwalah (Continuity)
Washing the next limb before the previous one dries.
Narrated from Umar bin Khattab:
> أَنَّ رَجُلاً تَوَضَّأَ فَتَرَكَ مَوْضِعَ ظُفُرٍ عَلَى قَدَمِهِ فَأَبْصَرَهُ النَّبِىُّ -صلى الله عليه وسلم- فَقَالَ « ارْجِعْ فَأَحْسِنْ وُضُوءَكَ ». فَرَجَعَ ثُمَّ صَلَّى
>
> *"A man performed wudhu and left a spot the size of a fingernail on his foot unwashed. The Prophet saw him and said, 'Go back and perform your wudhu well.' So he went back and then prayed."*
''',
    ),
    WudhuModel(
      id: 'wudhu_6',
      order: 6,
      title: 'Sunnah of Wudhu',
      description: 'Recommended actions to perfect your wudhu.',
      contentMarkdown: r'''
# Sunnah of Wudhu

### a. Siwak (Toothstick)
> « لَوْلاَ أَنْ أَشُقَّ عَلَى أُمَّتِى لأَمَرْتُهُمْ بِالسِّوَاكِ عِنْدَ كُلِّ صَلاَةٍ »
>
> *"If it were not a burden on my Ummah, I would have ordered them to use Siwak at every prayer (or wudhu)."*

### b. Washing Hands (3x) at the Beginning
> «وَإِذَا اسْتَيْقَظَ أَحَدُكُمْ مِنْ نَوْمِهِ فَلْيَغْسِلْ يَدَهُ قَبْلَ أَنْ يُدْخِلَهَا فِى وَضُوئِهِ ، فَإِنَّ أَحَدَكُمْ لاَ يَدْرِى أَيْنَ بَاتَتْ يَدُهُ »
>
> *"When one of you wakes up from sleep, let him wash his hands before putting them into the wudhu water, for one of you does not know where his hand spent the night."*

### c. Thoroughness in Sniffing Water (Istinshaq)
> « بَالِغْ فِى الاِسْتِنْشَاقِ إِلاَّ أَنْ تَكُونَ صَائِمًا »
>
> *"Exaggerate in sniffing water (Istinshaq) unless you are fasting."*

### d. Starting with the Right (Tayamun)
> « كَانَ رَسُولُ اللَّهِ -صلى الله عليه وسلم- لَيُحِبُّ التَّيَمُّنَ فِى طُهُورِهِ إِذَا تَطَهَّرَ »
>
> *"The Prophet (peace be upon him) used to love starting with the right side when purifying himself (wudhu)."*

### e. Washing 2x or 3x
> أَنَّ النَّبِىَّ – صلى الله عليه وسلم – تَوَضَّأَ مَرَّتَيْنِ مَرَّتَيْنِ
>
> *"The Prophet (peace be upon him) performed wudhu washing each part twice twice."* (Washing 3x is also Sunnah).

### f. Tartib (Order) based on Quran
Hadith of Al Miqdam bin Ma’dikarib:
> *"The Prophet performed wudhu by washing his hands three times, then rinsing his mouth and nose three times, then washing his face three times, then washing his arms three times, then wiping his head and ears (inside and out)."*

### g. Supplication (Dua) after Wudhu
> « مَا مِنْكُمْ مِنْ أَحَدٍ يَتَوَضَّأُ فَيُبْلِغُ – أَوْ فَيُسْبِغُ – الْوُضُوءَ ثُمَّ يَقُولُ أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَنَّ مُحَمَّدًا عَبْدُ اللَّهِ وَرَسُولُهُ إِلاَّ فُتِحَتْ لَهُ أَبْوَابُ الْجَنَّةِ الثَّمَانِيَةُ يَدْخُلُ مِنْ أَيِّهَا شَاءَ »
>
> *"No one among you performs wudhu and perfects it, then says, 'I bear witness that there is no god but Allah and that Muhammad is the servant of Allah and His Messenger,' except that the eight gates of Paradise are opened for him, and he may enter from whichever one he wishes."*

Addition from Tirmidhi:
> اللَّهُمَّ اجْعَلْنِى مِنَ التَّوَّابِينَ وَاجْعَلْنِى مِنَ الْمُتَطَهِّرِينَ
>
> *"O Allah, make me among those who repent and make me among those who purify themselves."*

### h. Praying Two Rakaat after Wudhu (Sunnah Wudhu)
> « مَنْ تَوَضَّأَ نَحْوَ وُضُوئِى هَذَا ثُمَّ صَلَّى رَكْعَتَيْنِ ، لاَ يُحَدِّثُ فِيهِمَا نَفْسَهُ ، غَفَرَ اللَّهُ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ »
>
> *"Whoever performs wudhu like this wudhu of mine, then prays two rakaat (with focus) without talking to himself, his past sins will be forgiven."*
''',
    ),
  ];
}
