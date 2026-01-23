import '../../domain/entities/zikir_item.dart';

class ZikirLocalRepository {
  List<ZikirItem> getMorningZikir() {
    return const [
      ZikirItem(
        id: 1,
        title: "Ayat Kursi",
        arabic:
            "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّحِيمِ\nاللهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ، لاَ تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ، لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ، يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ، وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ، وَلَا يَئُودُهُ حِفْظُهُمَا، وَهُوَ الْعَلِيُّ الْعَظِيمُ",
        translation:
            "Aku berlindung kepada Allah dari godaan syaitan yang terkutuk.\nAllah tidak ada Ilah (yang berhak diibadahi) melainkan Dia Yang Hidup Kekal lagi terus menerus mengurus (makhluk-Nya); tidak mengantuk dan tidak tidur. Kepunyaan-Nya apa yang ada di langit dan di bumi. Tidak ada yang dapat memberi syafa'at di sisi Allah tanpa izin-Nya. Allah mengetahui apa-apa yang (berada) dihadapan mereka, dan dibelakang mereka dan mereka tidak mengetahui apa-apa dari Ilmu Allah melainkan apa yang dikehendaki-Nya. Kursi Allah meliputi langit dan bumi. Dan Allah tidak merasa berat memelihara keduanya, Allah Mahatinggi lagi Mahabesar.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 2,
        title: "Surat Al-Ikhlas",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ . اللَّهُ الصَّمَدُ . لَمْ يَلِدْ وَلَمْ يُولَدْ . وَلَمْ يَكُن لَّهُ كُفُواً أَحَدٌ",
        translation:
            "Dengan menyebut Nama Allah Yang Mahapemurah lagi Mahapenyayang.\nKatakanlah, Dia-lah Allah Yang Mahaesa. Allah adalah (Rabb) yang segala sesuatu bergantung kepada-Nya. Dia tidak beranak dan tidak pula diperanakkan. Dan tidak ada seorang pun yang setara dengan-Nya.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 3,
        title: "Surat Al-Falaq",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ . مِن شَرِّ مَا خَلَقَ . وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ . وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ . وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ",
        translation:
            "Dengan menyebut Nama Allah Yang Mahapemurah lagi Mahapenyayang.\nKatakanlah: 'Aku berlindung kepada Rabb Yang menguasai (waktu) Shubuh dari kejahatan makhluk-Nya. Dan dari kejahatan malam apabila telah gelap gulita. Dan dari kejahatan wanita-wanita tukang sihir yang menghembus pada buhul-buhul. Serta dari kejahatan orang yang dengki apabila dia dengki.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 4,
        title: "Surat An-Naas",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ . مَلِكِ النَّاسِ . إِلَهِ النَّاسِ . مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ . الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ . مِنَ الْجِنَّةِ وَ النَّاسِ",
        translation:
            "Dengan menyebut Nama Allah Yang Mahapemurah lagi Mahapenyayang.\nKatakanlah, 'Aku berlindung kepada Rabb (yang memelihara dan menguasai) manusia. Raja manusia. Sembahan (Ilah) manusia. Dari kejahatan (bisikan) syaitan yang biasa bersembunyi. Yang membisikkan (kejahatan) ke dalam dada-dada manusia. Dari golongan jin dan manusia.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 5,
        title: "Dzikir Pagi 1",
        arabic:
            "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إِلَّا اللهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرُ . رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوْذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوْذُ بِكَ مِنَ الْكَسَلِ وَسُوْءِ الْكِبَرِ، رَبِّ أَعُوْذُ بِكَ مِنْ عَذَابِ فِي النَّارِ وَعَذَابِ فِي الْقَبْرِ",
        translation:
            "Kami telah memasuki waktu pagi dan kerajaan hanya milik Allah, segala puji hanya milik Allah. Tidak ada Ilah (yang berhak diibadahi dengan benar) kecuali Allah Yang Mahaesa, tiada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya pujian. Dia-lah Yang Mahakuasa atas segala sesuatu. Wahai Rabb, aku mohon kepada-Mu kebaikan di hari ini dan kebaikan sesudahnya. Aku berlindung kepada-Mu dari kejahatan hari ini dan kejahatan sesudahnya. Wahai Rabb, aku berlindung kepada-Mu dari kemalasan dan kejelekan di hari tua. Wahai Rabb, aku berlindung kepada-Mu dari siksaan di Neraka dan siksaan di kubur.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 6,
        title: "Dzikir Pagi 2",
        arabic:
            "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا ، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
        translation:
            "Ya Allah, dengan rahmat dan pertolongan-Mu kami memasuki waktu pagi, dan dengan rahmat dan pertolongan-Mu kami memasuki waktu sore. Dengan rahmat dan kehendak-Mu kami hidup dan dengan rahmat dan kehendak-Mu kami mati. Dan kepada-Mu kebangkitan (bagi semua makhluk).",
        targetCount: 1,
      ),
      ZikirItem(
        id: 7,
        title: "Sayyidul Istighfar",
        arabic:
            "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوْءُ بِذَنْبِي فَاغْفِرْ لي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
        translation:
            "Ya Allah, Engkau adalah Rabb-ku, tidak ada Ilah (yang berhak diibadahi dengan benar) kecuali Engkau, Engkau-lah yang menciptakanku. Aku adalah hamba-Mu. Aku akan setia pada perjanjianku dengan-Mu semampuku. Aku berlindung kepada-Mu dari kejelekan (apa) yang kuperbuat. Aku mengakui nikmat-Mu (yang diberikan) kepadaku dan aku mengakui dosaku, oleh karena itu, ampunilah aku. Sesungguhnya tidak ada yang dapat mengampuni dosa kecuali Engkau.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 8,
        title: "Dzikir Keselamatan Tubuh",
        arabic:
            "اَللَّهُمَّ عَافِنِي فِي بَدَنِي، اَللَّهُمَّ عَافِنِي فِي سَمْعِي، اَللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ، اَللَّهُمَّ إِنِّي أَعُوْذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوْذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إلا أَنْتَ",
        translation:
            "Ya Allah, selamatkanlah tubuhku (dari penyakit dan dari apa yang tidak aku inginkan). Ya Allah, selamatkanlah pendengaranku (dari penyakit dan maksiat atau dari apa yang tidak aku inginkan). Ya Allah, selamatkanlah penglihatanku, tidak ada Ilah (yang berhak diibadahi) kecuali Engkau. Ya Allah, sesungguhnya aku berlindung kepada-Mu dari kekufuran dan kefakiran. Aku berlindung kepada-Mu dari siksa kubur, tidak ada Ilah (yang berhak diibadahi) kecuali Engkau.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 9,
        title: "Dzikir Mohon 'Afiyah",
        arabic:
            "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي . اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي. اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوْذُ بِعَظَمَتِكَ أَنْ أَغْتَالَ مِنْ تَحْتِي",
        translation:
            "Ya Allah, sesungguhnya aku memohon kebajikan dan keselamatan di dunia dan akhirat. Ya Allah, sesungguhnya aku memohon kebajikan dan keselamatan dalam agama, dunia, keluarga dan hartaku. Ya Allah, tutupilah auratku (aib dan sesuatu yang tidak layak dilihat orang) dan tentramkan-lah aku dari rasa takut. Ya Allah, peliharalah aku dari depan, belakang, kanan, kiri dan dari atasku. Aku berlindung dengan kebesaran-Mu, agar aku tidak disambar dari bawahku (aku berlindung dari dibenamkan ke dalam bumi).",
        targetCount: 1,
      ),
      ZikirItem(
        id: 10,
        title: "Dzikir 'Alimul Ghaib",
        arabic:
            "اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيْكَهُ، أَشْهَدُ أَنْ لاَ إِلَهَ إِلا أَنْتَ، أَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوْءًا أَوْ أَجُرُّهُ إِلَى مُسْلِمٍ",
        translation:
            "Ya Allah Yang Mahamengetahui yang ghaib dan yang nyata, wahai Rabb Pencipta langit dan bumi, Rabb atas segala sesuatu dan Yang Merajainya. Aku bersaksi bahwa tidak ada Ilah (yang berhak diibadahi) kecuali Engkau. Aku berlindung kepada-Mu dari kejahatan diriku, syaitan dan sekutunya, (aku berlindung kepada-Mu) dari berbuat kejelekan atas diriku atau mendorong seorang muslim kepadanya..",
        targetCount: 1,
      ),
      ZikirItem(
        id: 11,
        title: "Dzikir Perlindungan",
        arabic:
            "بِسْمِ اللهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلاَ فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
        translation:
            "Dengan Nama Allah yang tidak ada bahaya atas Nama-Nya sesuatu di bumi dan tidak pula dilangit. Dia-lah Yang Mahamendengar dan Mahamengetahui.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 12,
        title: "Dzikir Ridha",
        arabic:
            "رَضِيْتُ بِاللهِ رَبًّا، وَبِالإِسْلامِ دِينًا ، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا",
        translation:
            "Aku rela (ridha) Allah sebagai Rabb-ku (untukku dan orang lain), Islam sebagai agamaku dan Muhammad صلى الله عليه وسلم sebagai Nabiku (yang diutus oleh Allah).",
        targetCount: 3,
      ),
      ZikirItem(
        id: 13,
        title: "Dzikir Ya Hayyu Ya Qayyum",
        arabic:
            "يَا حَيُّ يَا قَيُّوْمُ بِرَحْمَتِكَ أَسْتَغِيْتُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ",
        translation:
            "Wahai Rabb Yang Mahahidup, Wahai Rabb Yang berdiri sendiri (tidak butuh segala sesuatu) dengan rahmat-Mu aku meminta pertolongan, perbaikilah segala urusanku dan jangan diserahkan kepadaku meski sekejap mata sekali pun (tanpa mendapat pertolongan dari-Mu).",
        targetCount: 1,
      ),
      ZikirItem(
        id: 14,
        title: "Dzikir Fitrah",
        arabic:
            "أَصْبَحْنَا عَلَى فِطْرَةِ الإِسْلَامِ وَعَلَى كَلِمَةِ الإِخْلاَصِ، وَعَلَى دِيْنِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِيْنَا إِبْرَاهِيمَ، حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ",
        translation:
            "Di waktu pagi kami berada diatas fitrah agama Islam, kalimat ikhlas, agama Nabi kami Muhammad صلى الله عليه وسلم dan agama ayah kami, Ibrahim, yang berdiri di atas jalan yang lurus, muslim dan tidak tergolong orang-orang musyrik.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 15,
        title: "Dzikir Tasbih",
        arabic:
            "سُبْحَانَ اللهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ",
        translation:
            "Mahasuci Allah, aku memuji-Nya sebanyak bilangan makhluk-Nya, Mahasuci Allah sesuai keridhaan-Nya, Mahasuci seberat timbangan 'Arsy-Nya, dan Mahasuci sebanyak tinta (yang menulis) kalimat-Nya.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 16,
        title: "Dzikir Ilmu",
        arabic:
            "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلاً مُتَقَبَّلاً",
        translation:
            "Ya Allah, sesungguhnya aku meminta kepada-Mu ilmu yang bermanfaat, rizki yang halal, dan amalan yang diterima.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 17,
        title: "Tahlil",
        arabic:
            "لاَ إِلَهَ إِلَّا اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرُ",
        translation:
            "Tidak ada Ilah (yang berhak diibadahi dengan benar) selain Allah Yang Mahaesa, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya segala puji. Dan Dia Mahakuasa atas segala sesuatu.",
        targetCount: 10,
      ),
      ZikirItem(
        id: 18,
        title: "Tasbih 100x",
        arabic: "سُبْحَانَ اللهِ وَبِحَمْدِهِ",
        translation: "Mahasuci Allah, aku memuji-Nya.",
        targetCount: 100,
      ),
      ZikirItem(
        id: 19,
        title: "Istighfar",
        arabic: "أَسْتَغْفِرُ اللهَ وَأَتُوْبُ إِلَيْهِ",
        translation:
            "Aku memohon ampunan kepada Allah dan bertaubat kepada-Nya.",
        targetCount: 100,
      ),
    ];
  }

  List<ZikirItem> getEveningZikir() {
    return const [
      ZikirItem(
        id: 50,
        title: "Ayat Kursi",
        arabic:
            "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّحِيمِ\nاللهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ، لاَ تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ، لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ، يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ، وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ، وَلَا يَئُودُهُ حِفْظُهُمَا، وَهُوَ الْعَلِيُّ الْعَظِيمُ",
        translation:
            "Aku berlindung kepada Allah dari godaan syaitan yang terkutuk.\nAllah tidak ada Ilah (yang berhak diibadahi) melainkan Dia Yang Hidup Kekal lagi terus menerus mengurus (makhluk-Nya); tidak mengantuk dan tidak tidur. Kepunyaan-Nya apa yang ada di langit dan di bumi. Tidak ada yang dapat memberi syafa'at di sisi Allah tanpa izin-Nya. Allah mengetahui apa-apa yang (berada) dihadapan mereka, dan dibelakang mereka dan mereka tidak mengetahui apa-apa dari Ilmu Allah melainkan apa yang dikehendaki-Nya. Kursi Allah meliputi langit dan bumi. Dan Allah tidak merasa berat memelihara keduanya, Allah Mahatinggi lagi Mahabesar.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 51,
        title: "Surat Al-Ikhlas",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ . اللَّهُ الصَّمَدُ . لَمْ يَلِدْ وَلَمْ يُولَدْ . وَلَمْ يَكُن لَّهُ كُفُواً أَحَدٌ",
        translation:
            "Dengan menyebut Nama Allah Yang Mahapemurah lagi Mahapenyayang.\nKatakanlah, Dia-lah Allah Yang Mahaesa. Allah adalah (Rabb) yang segala sesuatu bergantung kepada-Nya. Dia tidak beranak dan tidak pula diperanakkan. Dan tidak ada seorang pun yang setara dengan-Nya.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 52,
        title: "Surat Al-Falaq",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ . مِن شَرِّ مَا خَلَقَ . وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ . وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ . وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ",
        translation:
            "Dengan menyebut Nama Allah Yang Mahapemurah lagi Mahapenyayang.\nKatakanlah: 'Aku berlindung kepada Rabb Yang menguasai (waktu) Shubuh dari kejahatan makhluk-Nya. Dan dari kejahatan malam apabila telah gelap gulita. Dan dari kejahatan wanita-wanita tukang sihir yang menghembus pada buhul-buhul. Serta dari kejahatan orang yang dengki apabila dia dengki.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 53,
        title: "Surat An-Naas",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ . مَلِكِ النَّاسِ . إِلَهِ النَّاسِ . مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ . الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ . مِنَ الْجِنَّةِ وَ النَّاسِ",
        translation:
            "Dengan menyebut Nama Allah Yang Mahapemurah lagi Mahapenyayang.\nKatakanlah, 'Aku berlindung kepada Rabb (yang memelihara dan menguasai) manusia. Raja manusia. Sembahan (Ilah) manusia. Dari kejahatan (bisikan) syaitan yang biasa bersembunyi. Yang membisikkan (kejahatan) ke dalam dada-dada manusia. Dari golongan jin dan manusia.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 54,
        title: "Dzikir Petang 1",
        arabic:
            "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ للهِ، وَالْحَمْدُ للهِ ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُبِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا ، رَبِّ أَعُوذُبِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُبِكَ مِنْ عَذَابِ فِي النَّارِ وَعَذَابِ فِي الْقَبْرِ",
        translation:
            "Kami telah memasuki waktu sore dan kerajaan hanya milik Allah, segala puji hanya milik Allah. Tidak ada Ilah (yang berhak diibadahi dengan benar) kecuali Allah Yang Mahaesa, tiada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya pujian. Dia-lah Yang Mahakuasa atas segala sesuatu. Wahai Rabb, aku mohon kepada-Mu kebaikan di malam ini dan kebaikan sesudahnya. Aku berlindung kepada-Mu dari kejahatan malam ini dan kejahatan sesudahnya. Wahai Rabb, aku berlindung kepada-Mu dari kemalasan dan kejelekan di hari tua. Wahai Rabb, aku berlindung kepada-Mu dari siksaan di Neraka dan siksaan di kubur.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 55,
        title: "Dzikir Petang 2",
        arabic:
            "اَللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوْتُ وَإِلَيْكَ الْمَصِيرُ",
        translation:
            "Ya Allah, dengan rahmat dan pertolongan-Mu kami memasuki waktu sore, dan dengan rahmat dan pertolongan-Mu kami memasuki waktu pagi. Dengan rahmat dan kehendak-Mu kami hidup dan dengan rahmat dan kehendak-Mu kami mati. Dan kepada-Mu tempat kembali (bagi semua makhluk).",
        targetCount: 1,
      ),
      ZikirItem(
        id: 56,
        title: "Sayyidul Istighfar",
        arabic:
            "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوْءُ بِذَنْبِي فَاغْفِرْ لي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
        translation:
            "Ya Allah, Engkau adalah Rabb-ku, tidak ada Ilah (yang berhak diibadahi dengan benar) kecuali Engkau, Engkau-lah yang menciptakanku. Aku adalah hamba-Mu. Aku akan setia pada perjanjianku dengan-Mu semampuku. Aku berlindung kepada-Mu dari kejelekan (apa) yang kuperbuat. Aku mengakui nikmat-Mu (yang diberikan) kepadaku dan aku mengakui dosaku, oleh karena itu, ampunilah aku. Sesungguhnya tidak ada yang dapat mengampuni dosa kecuali Engkau.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 58,
        title: "Dzikir Keselamatan Tubuh",
        arabic:
            "اَللَّهُمَّ عَافِنِي فِي بَدَنِي، اَللَّهُمَّ عَافِنِي فِي سَمْعِي، اَللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ، اَللَّهُمَّ إِنِّي أَعُوْذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوْذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إلا أَنْتَ",
        translation:
            "Ya Allah, selamatkanlah tubuhku (dari penyakit dan dari apa yang tidak aku inginkan). Ya Allah, selamatkanlah pendengaranku (dari penyakit dan maksiat atau dari apa yang tidak aku inginkan). Ya Allah, selamatkanlah penglihatanku, tidak ada Ilah (yang berhak diibadahi) kecuali Engkau. Ya Allah, sesungguhnya aku berlindung kepada-Mu dari kekufuran dan kefakiran. Aku berlindung kepada-Mu dari siksa kubur, tidak ada Ilah (yang berhak diibadahi) kecuali Engkau.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 57,
        title: "Dzikir Mohon 'Afiyah",
        arabic:
            "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي . اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي. اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوْذُ بِعَظَمَتِكَ أَنْ أَغْتَالَ مِنْ تَحْتِي",
        translation:
            "Ya Allah, sesungguhnya aku memohon kebajikan dan keselamatan di dunia dan akhirat. Ya Allah, sesungguhnya aku memohon kebajikan dan keselamatan dalam agama, dunia, keluarga dan hartaku. Ya Allah, tutupilah auratku (aib dan sesuatu yang tidak layak dilihat orang) dan tentramkan-lah aku dari rasa takut. Ya Allah, peliharalah aku dari depan, belakang, kanan, kiri dan dari atasku. Aku berlindung dengan kebesaran-Mu, agar aku tidak disambar dari bawahku (aku berlindung dari dibenamkan ke dalam bumi).",
        targetCount: 1,
      ),
      ZikirItem(
        id: 59,
        title: "Dzikir 'Alimul Ghaib",
        arabic:
            "اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيْكَهُ، أَشْهَدُ أَنْ لاَ إِلَهَ إِلا أَنْتَ، أَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوْءًا أَوْ أَجُرُّهُ إِلَى مُسْلِمٍ",
        translation:
            "Ya Allah Yang Mahamengetahui yang ghaib dan yang nyata, wahai Rabb Pencipta langit dan bumi, Rabb atas segala sesuatu dan Yang Merajainya. Aku bersaksi bahwa tidak ada Ilah (yang berhak diibadahi) kecuali Engkau. Aku berlindung kepada-Mu dari kejahatan diriku, syaitan dan sekutunya, (aku berlindung kepada-Mu) dari berbuat kejelekan atas diriku atau mendorong seorang muslim kepadanya..",
        targetCount: 1,
      ),
      ZikirItem(
        id: 60,
        title: "Dzikir Perlindungan",
        arabic:
            "بِسْمِ اللهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلاَ فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
        translation:
            "Dengan Nama Allah yang tidak ada bahaya atas Nama-Nya sesuatu di bumi dan tidak pula dilangit. Dia-lah Yang Mahamendengar dan Mahamengetahui.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 61,
        title: "Dzikir Ridha",
        arabic:
            "رَضِيْتُ بِاللهِ رَبًّا، وَبِالإِسْلامِ دِينًا ، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا",
        translation:
            "Aku rela (ridha) Allah sebagai Rabb-ku (untukku dan orang lain), Islam sebagai agamaku dan Muhammad صلى الله عليه وسلم sebagai Nabiku (yang diutus oleh Allah).",
        targetCount: 3,
      ),
      ZikirItem(
        id: 62,
        title: "Dzikir Ya Hayyu Ya Qayyum",
        arabic:
            "يَا حَيُّ يَا قَيُّوْمُ بِرَحْمَتِكَ أَسْتَغِيْتُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ",
        translation:
            "Wahai Rabb Yang Mahahidup, Wahai Rabb Yang berdiri sendiri (tidak butuh segala sesuatu) dengan rahmat-Mu aku meminta pertolongan, perbaikilah segala urusanku dan jangan diserahkan kepadaku meski sekejap mata sekali pun (tanpa mendapat pertolongan dari-Mu).",
        targetCount: 1,
      ),
      ZikirItem(
        id: 63,
        title: "Dzikir Fitrah Sore",
        arabic:
            "أَمْسَيْنَا عَلَى فِطْرَةِ الإِسْلَامِ وَعَلَى كَلِمَةِ الإِخْلاَصِ، وَعَلَى دِيْنِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِيْنَا إِبْرَاهِيمَ، حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ",
        translation:
            "Di waktu sore kami berada diatas fitrah agama Islam, kalimat ikhlas, agama Nabi kami Muhammad صلى الله عليه وسلم dan agama ayah kami, Ibrahim, yang berdiri di atas jalan yang lurus, muslim dan tidak tergolong orang-orang musyrik.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 64,
        title: "Tahlil",
        arabic:
            "لاَ إِلَهَ إِلَّا اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرُ",
        translation:
            "Tidak ada Ilah (yang berhak diibadahi dengan benar) selain Allah Yang Mahaesa, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya segala puji. Dan Dia Mahakuasa atas segala sesuatu.",
        targetCount: 10,
      ),
      ZikirItem(
        id: 65,
        title: "Tasbih 100x",
        arabic: "سُبْحَانَ اللهِ وَبِحَمْدِهِ",
        translation: "Mahasuci Allah, aku memuji-Nya.",
        targetCount: 100,
      ),
      ZikirItem(
        id: 66,
        title: "Dzikir Perlindungan (Kalimatillah)",
        arabic: "أَعُوْذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
        translation:
            "Aku berlindung dengan kalimat-kalimat Allah yang sempurna, dari kejahatan sesuatu yang diciptakan-Nya.",
        targetCount: 3,
      ),
    ];
  }

  List<ZikirItem> getPrayerZikir() {
    return const [
      ZikirItem(
        id: 100,
        title: "Istighfar",
        arabic: "أَسْتَغْفِرُ اللهَ",
        translation: "Aku memohon ampun kepada Allah.",
        targetCount: 3,
      ),
      ZikirItem(
        id: 101,
        title: "Doa Keselamatan",
        arabic:
            "اللَّهُمَّ أَنْتَ السَّلاَمُ، وَمِنْكَ السَّلاَمُ، تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالْإِكْرَامِ",
        translation:
            "Ya Allah, Engkau Mahasejahtera, dan dari-Mu lah kesejahteraan, Mahasuci Engkau wahai Rabb pemilik keagungan dan kemuliaan.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 102,
        title: "Tahlil & Doa Tauhid",
        arabic:
            "لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. لاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللهِ، لاَ إِلَهَ إِلاَّ اللهُ، وَلاَ نَعْبُدُ إِلاَّ إِيَّاهُ، لَهُ النِّعْمَةُ وَلَهُ الْفَضْلُ وَلَهُ الثَّنَاءُ الْحَسَنُ، لاَ إِلَهَ إِلاَّ اللهُ مُخْلِصِينَ لَهُ الدِّينَ وَلَوْ كَرِهَ الْكَافِرُونَ",
        translation:
            "Tiada Ilah (yang berhak diibadahi dengan benar) selain Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan segala pujian. Dia Mahakuasa atas segala sesuatu. Tidak ada daya dan upaya kecuali dengan pertolongan Allah. Tiada Ilah (yang berhak diibadahi dengan benar) selain Allah. Kami tidak menyembah kecuali kepada-Nya. Bagi-Nya nikmat, anugerah, dan pujian yang baik. Tiada Ilah (yang berhak diibadahi dengan benar) selain Allah, dengan memurnikan ibadah hanya kepada-Nya, meskipun orang-orang kafir membencinya.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 103,
        title: "Doa Ketetapan Allah",
        arabic:
            "اللَّهُمَّ لا مَانِعَ لِما أعْطَيْتَ، ولَا مُعْطِيَ لِما مَنَعْتَ، ولَا يَنْفَعُ ذَا الجَدِّ مِنْكَ الجَدُّ",
        translation:
            "Ya Allah, tidak ada yang mencegah apa yang Engkau berikan dan tidak ada yang memberi apa yang Engkau cegah. Tidak berguna kekayaan dan kemuliaan (bagi pemiliknya). Dari Engkau-lah semua kekayaan dan kemuliaan.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 104,
        title: "Tasbih",
        arabic: "سُبْحَانَ اللهِ",
        translation: "Mahasuci Allah.",
        targetCount: 33,
      ),
      ZikirItem(
        id: 105,
        title: "Tahmid",
        arabic: "الْحَمْدُ لِلَّهِ",
        translation: "Segala puji bagi Allah.",
        targetCount: 33,
      ),
      ZikirItem(
        id: 106,
        title: "Takbir",
        arabic: "اللهُ أَكْبَرُ",
        translation: "Allah Mahabesar.",
        targetCount: 33,
      ),
      ZikirItem(
        id: 107,
        title: "Penutup Tasbih",
        arabic:
            "لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
        translation:
            "Tiada Ilah (yang berhak diibadahi dengan benar) selain Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan segala pujian. Dia Mahakuasa atas segala sesuatu.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 108,
        title: "Ayat Kursi",
        arabic:
            "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّحِيمِ\nاللهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ، لاَ تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ، لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ، يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ، وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ، وَلَا يَئُودُهُ حِفْظُهُمَا، وَهُوَ الْعَلِيُّ الْعَظِيمُ",
        translation:
            "Allah tidak ada Ilah (yang berhak diibadahi) melainkan Dia Yang Hidup Kekal lagi terus menerus mengurus (makhluk-Nya); tidak mengantuk dan tidak tidur. Kepunyaan-Nya apa yang ada di langit dan di bumi. Tidak ada yang dapat memberi syafa'at di sisi Allah tanpa izin-Nya. Allah mengetahui apa-apa yang (berada) dihadapan mereka, dan dibelakang mereka dan mereka tidak mengetahui apa-apa dari Ilmu Allah melainkan apa yang dikehendaki-Nya. Kursi Allah meliputi langit dan bumi. Dan Allah tidak merasa berat memelihara keduanya, Allah Mahatinggi lagi Mahabesar.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 109,
        title: "Surat Al-Ikhlas",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ . اللَّهُ الصَّمَدُ . لَمْ يَلِدْ وَلَمْ يُولَدْ . وَلَمْ يَكُن لَّهُ كُفُواً أَحَدٌ",
        translation:
            "Katakanlah: Dia-lah Allah, Yang Maha Esa. Allah adalah Tuhan yang bergantung kepada-Nya segala sesuatu. Dia tiada beranak dan tidak pula diperanakkan, dan tidak ada seorangpun yang setara dengan Dia.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 110,
        title: "Surat Al-Falaq",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ . مِن شَرِّ مَا خَلَقَ . وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ . وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ . وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ",
        translation:
            "Katakanlah: Aku berlindung kepada Tuhan Yang Menguasai subuh, dari kejahatan makhluk-Nya, dan dari kejahatan malam apabila telah gelap gulita, dan dari kejahatan wanita-wanita tukang sihir yang menghembus pada buhul-buhul, dan dari kejahatan pendengki bila ia dengki.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 111,
        title: "Surat An-Naas",
        arabic:
            "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ . مَلِكِ النَّاسِ . إِلَهِ النَّاسِ . مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ . الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ . مِنَ الْجِنَّةِ وَ النَّاسِ",
        translation:
            "Katakanlah: Aku berlindung kepada Tuhan (yang memelihara dan menguasai) manusia. Raja manusia. Sembahan manusia. Dari kejahatan (bisikan) syaitan yang biasa bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari (golongan) jin dan manusia.",
        targetCount: 1,
      ),
      ZikirItem(
        id: 112,
        title: "Tahlil 10x (Khusus Subuh & Maghrib)",
        arabic:
            "لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيتُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
        translation:
            "Tiada Ilah (yang berhak diibadahi dengan benar) selain Allah semata, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan segala pujian. Dia yang Menghidupkan dan Mematikan, dan Dia Mahakuasa atas segala sesuatu.",
        targetCount: 10,
      ),
      ZikirItem(
        id: 113,
        title: "Doa Ilmu & Rezeki (Khusus Subuh)",
        arabic:
            "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلاً مُتَقَبَّلاً",
        translation:
            "Ya Allah, sesungguhnya aku meminta kepada-Mu ilmu yang bermanfaat, rizki yang halal, dan amalan yang diterima.",
        targetCount: 1,
      ),
    ];
  }

  List<ZikirItem> getDailyDzikir() {
    return const [
      // 1. Doa mohon ampunan dan rahmat Allah
      ZikirItem(
        id: 201,
        title: "Mohon Ampunan & Rahmat (1)",
        arabic:
            "رَبِّ إِنِّي أَعُوذُ بِكَ أَنْ أَسْأَلَكَ مَا لَيْسَ لِي بِهِ عِلْمٌ وَإِلَّا تَغْفِرْ لِي وَتَرْحَمْنِي أَكُنْ مِنَ الْخَاسِرِينَ",
        translation:
            "Ya Tuhanku, sesungguhnya aku berlindung kepada Engkau dari memohon kepada Engkau sesuatu yang aku tiada mengetahui (hakekat)nya. Dan sekiranya Engkau tidak memberi ampun kepadaku, dan (tidak) menaruh belas kasihan kepadaku, niscaya aku akan termasuk orang-orang yang merugi.\n(QS. Huud: 47)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 202,
        title: "Mohon Ampunan & Rahmat (2)",
        arabic:
            "رَبَّنَا آمَنَّا فَاغْفِرْ لَنَا وَارْحَمْنَا وَأَنْتَ خَيْرُ الرَّاحِمِينَ",
        translation:
            "Ya Tuhan kami, kami telah beriman, maka ampunilah kami dan berilah kami rahmat dan Engkau adalah Pemberi rahmat Yang Paling Baik.\n(QS. Al-Mu’minun: 109)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 203,
        title: "Mohon Ampunan & Rahmat (3)",
        arabic: "رَبِّ اغْفِرْ وَارْحَمْ وَأَنْتَ خَيْرُ الرَّاحِمِينَ",
        translation:
            "Ya Tuhanku, berilah ampun dan berilah rahmat, dan Engkau adalah Pemberi rahmat Yang Paling baik.\n(QS. Al-Mu’minun: 118)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 204,
        title: "Mohon Ampunan & Ketetapan Hati",
        arabic:
            "رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
        translation:
            "Ya Tuhan kami, ampunilah dosa-dosa kami dan tindakan-tindakan kami yang berlebih-lebihan dalam urusan kami dan tetapkanlah pendirian kami, dan tolonglah kami terhadap kaum yang kafir.\n(QS. Ali Imran: 147)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 205,
        title: "Mohon Perlindungan Neraka",
        arabic:
            "رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ",
        translation:
            "Ya Tuhan kami, sesungguhnya kami telah beriman, maka ampunilah segala dosa kami dan peliharalah kami dari siksa neraka.\n(QS. Ali Imran: 16)",
        targetCount: 1,
      ),

      // 2. Doa agar tergolong orang-orang beriman & shalih
      ZikirItem(
        id: 206,
        title: "Mohon Hikmah & Golongan Shalih",
        arabic:
            "رَبِّ هَبْ لِي حُكْمًا وَأَلْحِقْنِي بِالصَّالِحِينَ وَاجْعَلْ لِي لِسَانَ صِدْقٍ فِي الْآخِرِينَ وَاجْعَلْنِي مِنْ وَرَثَةِ جَنَّةِ النَّعِيمِ",
        translation:
            "Ya Tuhanku, berikanlah kepadaku hikmah dan masukkanlah aku ke dalam golongan orang-orang yang saleh. Dan jadikanlah aku buah tutur yang baik bagi orang-orang (yang datang) kemudian. Dan jadikanlah aku termasuk orang-orang yang mempusakai surga yang penuh kenikmatan.\n(QS. Asy-Syu’ara: 83-85)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 207,
        title: "Mohon Dicatat Bersama Orang Beriman",
        arabic: "رَبَّنَا آمَنَّا فَاكْتُبْنَا مَعَ الشَّاهِدِينَ",
        translation:
            "Ya Tuhan kami, kami telah beriman, maka catatlah kami bersama orang-orang yang menjadi saksi (atas kebenaran Al Quran dan kenabian Muhammad).\n(QS. Al-Maidah: 83)",
        targetCount: 1,
      ),

      // 3. Doa agar diberikan keturunan yang shalih
      ZikirItem(
        id: 208,
        title: "Mohon Keturunan Shalih (1)",
        arabic: "رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنْتَ خَيْرُ الْوَارِثِينَ",
        translation:
            "Ya Tuhanku, janganlah Engkau membiarkan aku hidup seorang diri dan Engkaulah Waris Yang Paling Baik.\n(QS. Al-Anbiya: 89)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 209,
        title: "Mohon Keturunan Shalih (2)",
        arabic: "رَبِّ هَبْ لِي مِنَ الصَّالِحِينَ",
        translation:
            "Ya Tuhanku, anugrahkanlah kepadaku (seorang anak) yang termasuk orang-orang yang saleh.\n(QS. Ash-Shaffat: 100)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 210,
        title: "Mohon Keturunan Baik",
        arabic:
            "رَبِّ هَبْ لِي مِنْ لَدُنْكَ ذُرِّيَّةً طَيِّبَةً إِنَّكَ سَمِيعُ الدُّعَاءِ",
        translation:
            "Ya Tuhanku, berilah aku dari sisi Engkau seorang anak yang baik. Sesungguhnya Engkau Maha Pendengar doa.\n(QS. Ali Imran: 38)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 211,
        title: "Doa Keluarga Sakinah",
        arabic:
            "رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا",
        translation:
            "Ya Tuhan kami, anugrahkanlah kepada kami isteri-isteri kami dan keturunan kami sebagai penyenang hati (kami), dan jadikanlah kami imam bagi orang-orang yang bertakwa.\n(QS. Al-Furqan: 74)",
        targetCount: 1,
      ),

      // 4. Doa mohon ampunan Orang Tua & Mukminin
      ZikirItem(
        id: 212,
        title: "Ampunan Orang Tua & Mukmin",
        arabic:
            "رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ",
        translation:
            "Ya Tuhan kami, beri ampunlah aku dan kedua ibu bapaku dan sekalian orang-orang mukmin pada hari terjadinya hisab (hari kiamat).\n(QS. Ibrahim: 41)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 213,
        title: "Ampunan Saudara Seiman",
        arabic:
            "رَبَّنَا اغْفِرْ لَنَا وَلِإِخْوَانِنَا الَّذِينَ سَبَقُونَا بِالْإِيمَانِ وَلَا تَجْعَلْ فِي قُلُوبِنَا غِلًّا لِلَّذِينَ آمَنُوا رَبَّنَا إِنَّكَ رَءُوفٌ رَحِيمٌ",
        translation:
            "Ya Rabb kami, beri ampunlah kami dan saudara-saudara kami yang telah beriman lebih dulu dari kami, dan janganlah Engkau membiarkan kedengkian dalam hati kami terhadap orang-orang yang beriman; Ya Rabb kami, Sesungguhnya Engkau Maha Penyantun lagi Maha Penyayang.\n(QS. Al-Hasyr: 10)",
        targetCount: 1,
      ),

      // 5. Doa ketetapan Shalat
      ZikirItem(
        id: 214,
        title: "Tetap Mendirikan Shalat",
        arabic:
            "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ",
        translation:
            "Ya Tuhanku, jadikanlah aku dan anak cucuku orang-orang yang tetap mendirikan salat, ya Tuhan kami, perkenankanlah doaku.\n(QS. Ibrahim: 40)",
        targetCount: 1,
      ),

      // 6. Doa berlindung dari orang zhalim
      ZikirItem(
        id: 215,
        title: "Berlindung dari Orang Zhalim",
        arabic: "رَبِّ نَجِّنِي مِنَ الْقَوْمِ الظَّالِمِينَ",
        translation:
            "Ya Tuhanku, selamatkanlah aku dari orang-orang yang zalim.\n(QS. Al-Qashash: 21)",
        targetCount: 1,
      ),

      // 7. Doa agar diterima amal & tobat
      ZikirItem(
        id: 216,
        title: "Terima Amal & Tobat",
        arabic:
            "رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ وَتُبْ عَلَيْنَا إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ",
        translation:
            "Ya Tuhan kami, terimalah daripada kami (amalan kami), dan terimalah tobat kami. Sesungguhnya Engkaulah Yang Maha Penerima tobat lagi Maha Penyayang.\n(QS. Al-Baqarah: 127-128)",
        targetCount: 1,
      ),

      // 8. Doa Tawakal
      ZikirItem(
        id: 217,
        title: "Doa Tawakal (1)",
        arabic:
            "رَبَّنَا عَلَيْكَ تَوَكَّلْنَا وَإِلَيْكَ أَنَبْنَا وَإِلَيْكَ الْمَصِيرُ",
        translation:
            "Ya Tuhan kami, hanya kepada Engkaulah kami bertawakal dan hanya kepada Engkaulah kami bertobat dan hanya kepada Engkaulah kami kembali.\n(QS. Al-Mumtahanah: 4)",
        targetCount: 1,
      ),
      ZikirItem(
        id: 218,
        title: "Doa Tawakal (2)",
        arabic:
            "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
        translation:
            "Cukuplah Allah bagiku; tidak ada Tuhan selain Dia. Hanya kepada-Nya aku bertawakal dan Dia adalah Tuhan yang memiliki ‘Arsy yang agung.\n(QS. At-Taubah: 129)",
        targetCount: 7, // Sunnah to read 7x
      ),

      // 9. Doa Tambah Ilmu
      ZikirItem(
        id: 219,
        title: "Mohon Tambahan Ilmu",
        arabic: "رَبِّ زِدْنِي عِلْمًا",
        translation: "Ya Tuhanku, tambahkanlah aku ilmu.\n(QS. Thaha: 114)",
        targetCount: 1,
      ),

      // 10. Doa Sempurna Cahaya
      ZikirItem(
        id: 220,
        title: "Sempurnakan Cahaya & Ampunan",
        arabic:
            "رَبَّنَا أَتْمِمْ لَنَا نُورَنَا وَاغْفِرْ لَنَا إِنَّكَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
        translation:
            "Ya Rabb kami, sempurnakanlah bagi kami cahaya kami dan ampunilah kami; Sesungguhnya Engkau Maha Kuasa atas segala sesuatu.\n(QS. At-Tahrim: 8)",
        targetCount: 1,
      ),

      // 11. Doa Sapu Jagat
      ZikirItem(
        id: 221,
        title: "Kebaikan Dunia Akhirat",
        arabic:
            "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
        translation:
            "Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat dan peliharalah kami dari siksa neraka.\n(QS. Al-Baqarah: 201)",
        targetCount: 1,
      ),

      // 12. Doa Syukur
      ZikirItem(
        id: 222,
        title: "Mohon Ilham Bersyukur",
        arabic:
            "رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَى وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ وَأَدْخِلْنِي بِرَحْمَتِكَ فِي عِبَادِكَ الصَّالِحِينَ",
        translation:
            "Ya Tuhanku, berilah aku ilham untuk tetap mensyukuri nikmat Mu yang telah Engkau anugerahkan kepadaku dan kepada dua orang ibu bapakku dan untuk mengerjakan amal saleh yang Engkau ridhai; dan masukkanlah aku dengan rahmat-Mu ke dalam golongan hamba-hamba-Mu yang saleh.\n(QS. An-Naml: 19)",
        targetCount: 1,
      ),

      // 13. Doa Berlindung dari Setan
      ZikirItem(
        id: 223,
        title: "Berlindung dari Bisikan Setan",
        arabic:
            "رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ",
        translation:
            "Ya Tuhanku, aku berlindung kepada Engkau dari bisikan-bisikan syaitan dan aku berlindung (pula) kepada Engkau ya Tuhanku, dari kedatangan mereka kepadaku.\n(QS. Al-Mu’minun: 97-98)",
        targetCount: 1,
      ),

      // 14. Doa Hidayah
      ZikirItem(
        id: 224,
        title: "Tetap dalam Hidayah",
        arabic:
            "رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ",
        translation:
            "Ya Tuhan kami, janganlah Engkau jadikan hati kami condong kepada kesesatan sesudah Engkau beri petunjuk kepada kami, dan karuniakanlah kepada kami rahmat dari sisi Engkau; karena sesungguhnya Engkau-lah Maha Pemberi (karunia).\n(QS. Ali Imran: 8)",
        targetCount: 1,
      ),

      // 15. Doa Lapang Dada
      ZikirItem(
        id: 225,
        title: "Lapang Dada & Dimudahkan Urusan",
        arabic:
            "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي",
        translation:
            "Ya Tuhanku, lapangkanlah untukku dadaku, dan mudahkanlah untukku urusanku, dan lepaskanlah kekakuan dari lidahku, supaya mereka mengerti perkataanku.\n(QS. Thaha: 25-28)",
        targetCount: 1,
      ),

      // 16. Doa Keamanan Negeri
      ZikirItem(
        id: 226,
        title: "Keamanan Negeri",
        arabic:
            "رَبِّ اجْعَلْ هَذَا الْبَلَدَ آمِنًا وَاجْنُبْنِي وَبَنِيَّ أَنْ نَعْبُدَ الْأَصْنَامَ",
        translation:
            "Ya Tuhanku, jadikanlah negeri ini (Mekah), negeri yang aman, dan jauhkanlah aku beserta anak cucuku daripada menyembah berhala-berhala.\n(QS. Ibrahim: 35)",
        targetCount: 1,
      ),

      // 17. Doa Jauh dari Jahannam
      ZikirItem(
        id: 227,
        title: "Jauhkan Azab Jahannam",
        arabic:
            "رَبَّنَا اصْرِفْ عَنَّا عَذَابَ جَهَنَّمَ إِنَّ عَذَابَهَا كَانَ غَرَامًا إِنَّهَا سَاءَتْ مُسْتَقَرًّا وَمُقَامًا",
        translation:
            "Ya Tuhan kami, jauhkan azab jahannam dari kami, sesungguhnya azabnya itu adalah kebinasaan yang kekal. Sesungguhnya jahannam itu seburuk-buruk tempat menetap dan tempat kediaman.\n(QS. Al-Furqan: 65-66)",
        targetCount: 1,
      ),
    ];
  }
}
