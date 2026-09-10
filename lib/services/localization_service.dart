class L {
  static String _lang = 'en';

  static void setLanguage(String lang) => _lang = lang;

  static const _strings = <String, Map<String, String>>{
    // ── Home Screen ─────────────────────────────────────────────────────────
    'app_name': {'en': 'FarmHelper', 'hi': 'फार्म हेल्पर', 'bn': 'ফার্ম হেল্পার'},
    'tagline': {
      'en': 'Disease Detection',
      'hi': 'रोग पहचान',
      'bn': 'রোগ সনাক্তকরণ',
    },
    'hero_title': {
      'en': 'Diagnose\nCrop health',
      'hi': 'फसल स्वास्थ्य\nनिदान करें',
      'bn': 'ফসলের স্বাস্থ্য\nনির্ণয় করুন',
    },
    'hero_sub': {
      'en': 'Analyse plant vitality and detect instantly using advanced AI.',
      'hi': 'पौधे की जीवन शक्ति का विश्लेषण करें और उन्नत AI का उपयोग करके तुरंत पता लगाएं।',
      'bn': 'উদ্ভিদের জীবনীশক্তি বিশ্লেষণ করুন এবং উন্নত AI ব্যবহার করে তাৎক্ষণিকভাবে শনাক্ত করুন।',
    },
    'select_crop': {
      'en': 'SELECT CROP',
      'hi': 'फसल चुनें',
      'bn': 'ফসল বেছে নিন',
    },
    'more': {'en': 'MORE', 'hi': 'अधिक', 'bn': 'আরো'},
    'scan_history': {
      'en': 'Scan History',
      'hi': 'स्कैन इतिहास',
      'bn': 'স্ক্যান ইতিহাস',
    },
    'scan_history_sub': {
      'en': 'View your past scans',
      'hi': 'अपने पिछले स्कैन देखें',
      'bn': 'আপনার পূর্ববর্তী স্ক্যান দেখুন',
    },
    'farmer_profile': {
      'en': 'Farmer Profile',
      'hi': 'किसान प्रोफ़ाइल',
      'bn': 'কৃষক প্রোফাইল',
    },
    'farmer_profile_sub': {
      'en': 'Set your name & location',
      'hi': 'नाम और स्थान सेट करें',
      'bn': 'আপনার নাম ও অবস্থান সেট করুন',
    },
    'powered_by': {
      'en': 'Powered by Wavelet Neural Network',
      'hi': 'वेवलेट न्यूरल नेटवर्क द्वारा संचालित',
      'bn': 'ওয়েভলেট নিউরাল নেটওয়ার্ক দ্বারা চালিত',
    },
    'welcome_back': {
      'en': 'Welcome back',
      'hi': 'वापस स्वागत है',
      'bn': 'স্বাগতম আবার',
    },
    'disease_classes': {
      'en': 'disease classes',
      'hi': 'रोग वर्ग',
      'bn': 'রোগের শ্রেণি',
    },

    // ── Camera Screen ────────────────────────────────────────────────────────
    'scanner': {'en': 'SCANNER', 'hi': 'स्कैनर', 'bn': 'স্ক্যানার'},
    'ready': {'en': 'READY', 'hi': 'तैयार', 'bn': 'প্রস্তুত'},
    'loading': {'en': 'LOADING', 'hi': 'लोड हो रहा है', 'bn': 'লোড হচ্ছে'},
    'capture_leaf': {
      'en': 'Capture a leaf',
      'hi': 'पत्ती की फोटो लें',
      'bn': 'একটি পাতার ছবি তুলুন',
    },
    'use_camera_gallery': {
      'en': 'Use camera or gallery below',
      'hi': 'नीचे कैमरा या गैलरी उपयोग करें',
      'bn': 'নিচে ক্যামেরা বা গ্যালারি ব্যবহার করুন',
    },
    'camera': {'en': 'Camera', 'hi': 'कैमरा', 'bn': 'ক্যামেরা'},
    'gallery': {'en': 'Gallery', 'hi': 'गैलरी', 'bn': 'গ্যালারি'},
    'analyze_leaf': {
      'en': 'ANALYZE LEAF',
      'hi': 'पत्ती विश्लेषण करें',
      'bn': 'পাতা বিশ্লেষণ করুন',
    },
    'analyzing': {
      'en': 'ANALYZING LEAF',
      'hi': 'पत्ती विश्लेषण हो रहा है',
      'bn': 'পাতা বিশ্লেষণ করা হচ্ছে',
    },
    'ai_inference': {
      'en': 'Running AI inference...',
      'hi': 'AI विश्लेषण चल रहा है...',
      'bn': 'AI বিশ্লেষণ চলছে...',
    },
    'low_confidence': {
      'en': 'Low Confidence',
      'hi': 'कम विश्वास',
      'bn': 'কম আত্মবিশ্বাস',
    },
    'retake': {'en': 'Retake', 'hi': 'दोबारा लें', 'bn': 'আবার তুলুন'},
    'show_anyway': {
      'en': 'Show anyway',
      'hi': 'फिर भी दिखाएं',
      'bn': 'তবুও দেখান',
    },

    // ── Result Screen ────────────────────────────────────────────────────────
    'scan_result': {
      'en': 'SCAN RESULT',
      'hi': 'स्कैन परिणाम',
      'bn': 'স্ক্যান ফলাফল',
    },
    'healthy': {'en': 'HEALTHY', 'hi': 'स्वस्थ', 'bn': 'সুস্থ'},
    'disease_detected': {
      'en': 'DISEASE DETECTED',
      'hi': 'रोग मिला',
      'bn': 'রোগ সনাক্ত',
    },
    'leaf_analysis': {
      'en': 'Leaf Analysis',
      'hi': 'पत्ती विश्लेषण',
      'bn': 'পাতা বিশ্লেষণ',
    },
    'confidence': {
      'en': 'Confidence',
      'hi': 'विश्वास स्तर',
      'bn': 'আত্মবিশ্বাস',
    },
    'color_analysis': {
      'en': 'COLOR ANALYSIS',
      'hi': 'रंग विश्लेषण',
      'bn': 'রঙ বিশ্লেষণ',
    },
    'all_class_prob': {
      'en': 'ALL CLASS PROBABILITIES',
      'hi': 'सभी वर्ग संभावनाएं',
      'bn': 'সমস্ত শ্রেণীর সম্ভাবনা',
    },
    'treatment': {'en': 'TREATMENT', 'hi': 'उपचार', 'bn': 'চিকিৎসা'},
    'medicine': {'en': 'Medicine', 'hi': 'दवा', 'bn': 'ওষুধ'},
    'dosage': {'en': 'Dosage', 'hi': 'खुराक', 'bn': 'মাত্রা'},
    'frequency': {'en': 'Frequency', 'hi': 'आवृत्ति', 'bn': 'ফ্রিকোয়েন্সি'},
    'notes': {'en': 'Notes', 'hi': 'नोट्स', 'bn': 'নোট'},
    'healthy_msg': {
      'en': 'Leaf is Healthy! 🎉',
      'hi': 'पत्ती स्वस्थ है! 🎉',
      'bn': 'পাতাটি সুস্থ! 🎉',
    },
    'healthy_sub': {
      'en': 'No treatment needed. Continue regular care.',
      'hi': 'उपचार की जरूरत नहीं। नियमित देखभाल जारी रखें।',
      'bn': 'কোন চিকিৎসার প্রয়োজন নেই। নিয়মিত যত্ন চালিয়ে যান।',
    },
    'tips_care': {
      'en': 'TIPS & CARE',
      'hi': 'सुझाव और देखभाल',
      'bn': 'টিপস ও যত্ন',
    },
    'scan_another': {
      'en': 'SCAN ANOTHER LEAF',
      'hi': 'एक और पत्ती स्कैन करें',
      'bn': 'আরেকটি পাতা স্ক্যান করুন',
    },

    // ── History Screen ───────────────────────────────────────────────────────
    'scan_history_title': {
      'en': '📋 SCAN HISTORY',
      'hi': '📋 स्कैन इतिहास',
      'bn': '📋 স্ক্যান ইতিহাস',
    },
    'clear_all': {
      'en': 'Clear all',
      'hi': 'सब हटाएं',
      'bn': 'সব মুছুন',
    },
    'no_scans': {
      'en': 'No scans yet',
      'hi': 'कोई स्कैन नहीं',
      'bn': 'এখনো কোন স্ক্যান নেই',
    },
    'no_scans_sub': {
      'en': 'Your scan history will appear here',
      'hi': 'आपका स्कैन इतिहास यहाँ दिखेगा',
      'bn': 'আপনার স্ক্যান ইতিহাস এখানে দেখাবে',
    },
    'filter_all': {'en': 'All', 'hi': 'सभी', 'bn': 'সব'},
    'filter_today': {'en': 'Today', 'hi': 'आज', 'bn': 'আজ'},
    'filter_mango': {'en': 'Mango', 'hi': 'आम', 'bn': 'আম'},
    'filter_grape': {'en': 'Grape', 'hi': 'अंगूर', 'bn': 'আঙুর'},
    'delete_all': {
      'en': 'Delete all',
      'hi': 'सब हटाएं',
      'bn': 'সব মুছুন',
    },
    'clear_history': {
      'en': 'Clear History',
      'hi': 'इतिहास हटाएं',
      'bn': 'ইতিহাস মুছুন',
    },
    'delete_confirm': {
      'en': 'Delete all scan records?',
      'hi': 'सभी स्कैन रिकॉर्ड हटाएं?',
      'bn': 'সমস্ত স্ক্যান রেকর্ড মুছবেন?',
    },
    'cancel': {'en': 'Cancel', 'hi': 'रद्द करें', 'bn': 'বাতিল'},

    // ── Profile Screen ───────────────────────────────────────────────────────
    'farmer_profile_title': {
      'en': '👨‍🌾 FARMER PROFILE',
      'hi': '👨‍🌾 किसान प्रोफ़ाइल',
      'bn': '👨‍🌾 কৃষক প্রোফাইল',
    },
    'your_name': {
      'en': 'Your Name',
      'hi': 'आपका नाम',
      'bn': 'আপনার নাম',
    },
    'name_hint': {
      'en': 'e.g. Ramesh Patel',
      'hi': 'जैसे: रमेश पटेल',
      'bn': 'যেমন: রমেশ পাটেল',
    },
    'farm_location': {
      'en': 'Farm Location',
      'hi': 'खेत का स्थान',
      'bn': 'খামারের অবস্থান',
    },
    'location_hint': {
      'en': 'e.g. Nagpur, Maharashtra',
      'hi': 'जैसे: नागपुर, महाराष्ट्र',
      'bn': 'যেমন: নাগপুর, মহারাষ্ট্র',
    },
    'phone': {
      'en': 'Phone Number (optional)',
      'hi': 'फोन नंबर (वैकल्पिक)',
      'bn': 'ফোন নম্বর (ঐচ্ছিক)',
    },
    'phone_hint': {
      'en': 'e.g. 9876543210',
      'hi': 'जैसे: 9876543210',
      'bn': 'যেমন: 9876543210',
    },
    'preferred_crop': {
      'en': 'Preferred Crop',
      'hi': 'पसंदीदा फसल',
      'bn': 'পছন্দের ফসল',
    },
    'save_profile': {
      'en': 'SAVE PROFILE',
      'hi': 'प्रोफ़ाइल सहेजें',
      'bn': 'প্রোফাইল সেভ করুন',
    },
    'profile_saved': {
      'en': 'Profile saved ✓',
      'hi': 'प्रोफ़ाइल सहेजी ✓',
      'bn': 'প্রোফাইল সেভ হয়েছে ✓',
    },
  };

  static String t(String key) {
    return _strings[key]?[_lang] ?? _strings[key]?['en'] ?? key;
  }
}