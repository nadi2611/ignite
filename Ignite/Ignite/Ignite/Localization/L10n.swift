import SwiftUI
import Combine

// Global shorthand: L("key") → translated string
func L(_ key: String) -> String { L10n.shared[key] }

class L10n: ObservableObject {
    static let shared = L10n()

    @AppStorage("appLanguage") var language: String = {
        Locale.current.language.languageCode?.identifier == "ar" ? "ar" : "en"
    }() {
        didSet { objectWillChange.send() }
    }

    var isArabic: Bool { language == "ar" }
    var layoutDirection: LayoutDirection { isArabic ? .rightToLeft : .leftToRight }
    var locale: Locale { Locale(identifier: isArabic ? "ar" : "en") }

    subscript(_ key: String) -> String {
        let dict = isArabic ? L10n.ar : L10n.en
        return dict[key] ?? (L10n.en[key] ?? key)
    }

    // MARK: - English
    static let en: [String: String] = [
        // App
        "app_name": "Ignite",
        "app_tagline": "Find your spark",

        // Tabs
        "tab_discover": "Discover",
        "tab_matches": "Matches",
        "tab_messages": "Messages",
        "tab_profile": "Profile",

        // Welcome
        "welcome_create_account": "Create Account",
        "welcome_sign_in": "Sign In",
        "welcome_terms": "By continuing you agree to our Terms & Privacy Policy",

        // Auth
        "login_title": "Welcome back 🔥",
        "login_subtitle": "Sign in to continue",
        "login_email": "Email",
        "login_password": "Password",
        "login_button": "Sign In",
        "register_title": "Create account",
        "register_subtitle": "Let's get you started",
        "register_name": "Full Name",
        "register_password_hint": "Password (min 6 characters)",
        "register_button": "Continue",

        // Onboarding
        "onboarding_birthday_title": "When's your birthday?",
        "onboarding_birthday_subtitle": "Your age will be shown on your profile",
        "onboarding_birthday_age": "Age",
        "onboarding_gender_title": "I am a...",
        "onboarding_gender_subtitle": "Select your gender",
        "onboarding_city_title": "Where are you from?",
        "onboarding_city_subtitle": "This helps us find people near you",
        "onboarding_city_placeholder": "Your city",
        "onboarding_religion_title": "Your religion",
        "onboarding_religion_subtitle": "This helps find compatible matches",
        "onboarding_interests_title": "Your interests",
        "onboarding_interests_subtitle": "Pick at least 3 things you love",
        "onboarding_photo_title": "Add your best photo",
        "onboarding_photo_subtitle": "Profiles with photos get 10x more matches",
        "onboarding_photo_tap": "Tap to add photo",
        "onboarding_continue": "Continue",
        "onboarding_finish": "Let's go 🔥",

        // Gender options
        "gender_man": "Man",
        "gender_woman": "Woman",
        "gender_nonbinary": "Non-binary",

        // Religion categories
        "religion_cat_muslim": "Muslim",
        "religion_cat_christian": "Christian",
        "religion_cat_druze": "Druze",
        "religion_cat_other": "Other",

        // Religion options
        "religion_sunni": "Sunni Muslim",
        "religion_shia": "Shia Muslim",
        "religion_orthodox": "Greek Orthodox",
        "religion_melkite": "Greek Catholic (Melkite)",
        "religion_catholic": "Roman Catholic",
        "religion_maronite": "Maronite",
        "religion_evangelical": "Evangelical",
        "religion_baptist": "Baptist",
        "religion_druze": "Druze",
        "religion_secular": "Secular",
        "religion_prefer_not": "Prefer not to say",

        // Interests
        "interest_travel": "Travel",
        "interest_food": "Food",
        "interest_music": "Music",
        "interest_art": "Art",
        "interest_sports": "Sports",
        "interest_reading": "Reading",
        "interest_movies": "Movies",
        "interest_cooking": "Cooking",
        "interest_photography": "Photography",
        "interest_gaming": "Gaming",
        "interest_fitness": "Fitness",
        "interest_dancing": "Dancing",
        "interest_coffee": "Coffee",
        "interest_nature": "Nature",
        "interest_tech": "Tech",

        // Discover
        "discover_empty_title": "No more profiles",
        "discover_empty_subtitle": "Check back later!",

        // Match overlay
        "match_title": "It's a Match! 🔥",
        "match_send_message": "Send Message 💬",
        "match_keep_swiping": "Keep Swiping",

        // Matches
        "matches_empty_title": "No matches yet",
        "matches_empty_subtitle": "Keep swiping to find your spark",

        // Chat list
        "chat_empty_title": "No messages yet",
        "chat_empty_subtitle": "Start swiping to find your match!",
        "chat_say_hello": "Say hello 👋",
        "chat_yesterday": "Yesterday",

        // Chat
        "chat_placeholder": "Message...",

        // Profile
        "profile_edit": "Edit Profile",
        "profile_signout": "Sign Out",
        "profile_upgrade": "Upgrade to Premium",
        "profile_language": "Language",

        // Edit profile
        "edit_name": "Name",
        "edit_city": "City",
        "edit_bio": "Bio",
        "edit_name_placeholder": "Your name",
        "edit_city_placeholder": "Your city",
        "edit_bio_placeholder": "Tell people about yourself",
        "edit_save": "Save Changes",
        "edit_cancel": "Cancel",
        "edit_photo_failed": "Photo upload failed. Saving other changes.",
        "edit_religion": "Religion",
        "edit_interests": "Interests",

        // Paywall
        "paywall_title": "Upgrade Ignite",
        "paywall_subtitle": "Unlock your perfect match",
        "paywall_loading": "Loading plans...",
        "paywall_continue": "Continue",
        "paywall_restore": "Restore Purchases",
        "paywall_legal": "Subscription auto-renews monthly. Cancel anytime in App Store settings.",
        "paywall_best_value": "BEST VALUE",
        "paywall_per_month": "per month",
        "paywall_retry": "Retry",
        "paywall_features": "Features",
        "paywall_free": "Free",

        // Report/Block
        "report_title": "Report or Block",
        "report_photos": "Report: Inappropriate photos",
        "report_fake": "Report: Fake profile",
        "report_harassment": "Report: Harassment",
        "block_user": "Block",
        "action_cancel": "Cancel",
        "action_delete": "Delete",
    ]

    // MARK: - Arabic
    static let ar: [String: String] = [
        // App
        "app_name": "إغنايت",
        "app_tagline": "ابحث عن شرارتك",

        // Tabs
        "tab_discover": "اكتشف",
        "tab_matches": "تطابقات",
        "tab_messages": "رسائل",
        "tab_profile": "الملف",

        // Welcome
        "welcome_create_account": "إنشاء حساب",
        "welcome_sign_in": "تسجيل الدخول",
        "welcome_terms": "بالمتابعة توافق على شروط الخدمة وسياسة الخصوصية",

        // Auth
        "login_title": "أهلاً بعودتك 🔥",
        "login_subtitle": "سجّل دخولك للمتابعة",
        "login_email": "البريد الإلكتروني",
        "login_password": "كلمة المرور",
        "login_button": "دخول",
        "register_title": "إنشاء حساب",
        "register_subtitle": "يلا نبدأ",
        "register_name": "الاسم الكامل",
        "register_password_hint": "كلمة المرور (٦ أحرف على الأقل)",
        "register_button": "متابعة",

        // Onboarding
        "onboarding_birthday_title": "متى ميلادك؟",
        "onboarding_birthday_subtitle": "سيظهر عمرك على ملفك الشخصي",
        "onboarding_birthday_age": "العمر",
        "onboarding_gender_title": "أنا...",
        "onboarding_gender_subtitle": "اختر جنسك",
        "onboarding_city_title": "من أين أنت؟",
        "onboarding_city_subtitle": "هذا يساعدنا في إيجاد أشخاص قريبين منك",
        "onboarding_city_placeholder": "مدينتك",
        "onboarding_religion_title": "ديانتك",
        "onboarding_religion_subtitle": "هذا يساعد في إيجاد التوافقات المناسبة",
        "onboarding_interests_title": "اهتماماتك",
        "onboarding_interests_subtitle": "اختر على الأقل ٣ أشياء تحبها",
        "onboarding_photo_title": "أضف أفضل صورة لك",
        "onboarding_photo_subtitle": "الملفات مع صور تحصل على ١٠ أضعاف التوافقات",
        "onboarding_photo_tap": "اضغط لإضافة صورة",
        "onboarding_continue": "متابعة",
        "onboarding_finish": "يلا نبدأ 🔥",

        // Gender options
        "gender_man": "رجل",
        "gender_woman": "امرأة",
        "gender_nonbinary": "غير ثنائي",

        // Religion categories
        "religion_cat_muslim": "مسلم",
        "religion_cat_christian": "مسيحي",
        "religion_cat_druze": "درزي",
        "religion_cat_other": "أخرى",

        // Religion options
        "religion_sunni": "مسلم سني",
        "religion_shia": "مسلم شيعي",
        "religion_orthodox": "أرثوذكسي روماني",
        "religion_melkite": "كاثوليكي ملكيتي",
        "religion_catholic": "كاثوليكي لاتيني",
        "religion_maronite": "ماروني",
        "religion_evangelical": "إنجيلي",
        "religion_baptist": "باتيست",
        "religion_druze": "درزي",
        "religion_secular": "علماني",
        "religion_prefer_not": "أفضل عدم الذكر",

        // Interests
        "interest_travel": "سفر",
        "interest_food": "طعام",
        "interest_music": "موسيقى",
        "interest_art": "فن",
        "interest_sports": "رياضة",
        "interest_reading": "قراءة",
        "interest_movies": "أفلام",
        "interest_cooking": "طبخ",
        "interest_photography": "تصوير",
        "interest_gaming": "ألعاب",
        "interest_fitness": "لياقة",
        "interest_dancing": "رقص",
        "interest_coffee": "قهوة",
        "interest_nature": "طبيعة",
        "interest_tech": "تقنية",

        // Discover
        "discover_empty_title": "لا يوجد مزيد من الملفات",
        "discover_empty_subtitle": "تحقق لاحقاً!",

        // Match overlay
        "match_title": "تطابق! 🔥",
        "match_send_message": "أرسل رسالة 💬",
        "match_keep_swiping": "استمر في التمرير",

        // Matches
        "matches_empty_title": "لا يوجد تطابقات بعد",
        "matches_empty_subtitle": "استمر في التمرير لإيجاد شرارتك",

        // Chat list
        "chat_empty_title": "لا توجد رسائل بعد",
        "chat_empty_subtitle": "ابدأ التمرير لإيجاد تطابقك!",
        "chat_say_hello": "قل مرحبا 👋",
        "chat_yesterday": "أمس",

        // Chat
        "chat_placeholder": "رسالة...",

        // Profile
        "profile_edit": "تعديل الملف",
        "profile_signout": "تسجيل الخروج",
        "profile_upgrade": "الترقية إلى المميز",
        "profile_language": "اللغة",

        // Edit profile
        "edit_name": "الاسم",
        "edit_city": "المدينة",
        "edit_bio": "نبذة عني",
        "edit_name_placeholder": "اسمك",
        "edit_city_placeholder": "مدينتك",
        "edit_bio_placeholder": "أخبر الناس عن نفسك",
        "edit_save": "حفظ التغييرات",
        "edit_cancel": "إلغاء",
        "edit_photo_failed": "فشل تحميل الصورة. حفظ التغييرات الأخرى.",
        "edit_religion": "الدين",
        "edit_interests": "الاهتمامات",

        // Paywall
        "paywall_title": "ترقية إغنايت",
        "paywall_subtitle": "افتح بابك للتوافق المثالي",
        "paywall_loading": "جارٍ تحميل الخطط...",
        "paywall_continue": "متابعة",
        "paywall_restore": "استعادة المشتريات",
        "paywall_legal": "يتجدد الاشتراك تلقائياً كل شهر. يمكن الإلغاء في إعدادات App Store.",
        "paywall_best_value": "أفضل قيمة",
        "paywall_per_month": "شهرياً",
        "paywall_retry": "إعادة المحاولة",
        "paywall_features": "الميزات",
        "paywall_free": "مجاني",

        // Report/Block
        "report_title": "إبلاغ أو حظر",
        "report_photos": "إبلاغ: صور غير لائقة",
        "report_fake": "إبلاغ: ملف مزيف",
        "report_harassment": "إبلاغ: مضايقة",
        "block_user": "حظر",
        "action_cancel": "إلغاء",
        "action_delete": "حذف",
    ]
}
