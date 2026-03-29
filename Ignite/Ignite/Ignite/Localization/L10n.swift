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
        "phone_subtitle": "Enter your mobile number for secure verification",
        "phone_button": "Send Code",
        "phone_create_account": "New to Ignite? Create Account",
        "phone_already_have_account": "Already have an account? Sign In",
        "phone_change_number": "Change phone number",
        "otp_subtitle": "Enter the 6-digit code we sent to your phone",
        "otp_button": "Verify & Continue",

        // Verification
        "verification_title": "Get Verified",
        "verification_subtitle": "Prove you're the real you and get more trust",
        "verification_get_verified": "Get Verified",
        "verification_pending_title": "Verification Pending",
        "verification_pending_subtitle": "We're reviewing your selfie. This usually takes 24 hours.",
        "verification_step_1": "Take a Selfie",
        "verification_step_1_desc": "Take a clear photo of yourself looking at the camera",
        "verification_submit": "Submit for Review",
        "verification_success": "Submitted! We'll notify you once verified.",

        // Paywall
        "paywall_title": "Upgrade Ignite",
        "paywall_subtitle": "Unlock your perfect match",
        "paywall_spark": "Spark ⚡",
        "paywall_ignite": "Ignite 🔥",
        "paywall_spark_desc": "Unlimited likes + AI features",
        "paywall_ignite_desc": "All features + Family Mode",
        "paywall_best_value": "BEST VALUE",
        "paywall_per_month": "per month",
        "paywall_restore": "Restore Purchases",
        "paywall_legal": "Subscription auto-renews monthly. Cancel anytime in App Store settings.",
        "paywall_loading": "Loading plans...",
        "paywall_features_title": "Features",
        "paywall_feature_likes": "Daily Likes",
        "paywall_feature_see_likes": "See Who Liked You",
        "paywall_feature_ai": "AI Compatibility",
        "paywall_feature_voice": "Voice Intro",
        "paywall_feature_boosts": "Weekly Boosts",
        "paywall_feature_receipts": "Read Receipts",
        "paywall_feature_family": "Family Mode",
        "paywall_feature_priority": "Priority Queue",
        "paywall_continue": "Continue",
        "paywall_retry": "Retry",
        "paywall_features": "Features",
        "paywall_free": "Free",

        "plan_free": "Free",
        "plan_spark": "Spark",
        "plan_ignite": "Ignite",
        "common_unlimited": "Unlimited",

        // Rich Profile Fields
        "profile_origin": "Origin",
        "profile_height": "Height",
        "profile_smokes": "Smoking",
        "profile_prays": "Prayer",
        "profile_fasts": "Fasting",
        "profile_about_title": "About Me",
        "profile_basics_title": "The Basics",
        "profile_values_title": "Values & Faith",
        "profile_lifestyle_title": "Lifestyle",

        "smoke_yes": "Smoker",
        "smoke_no": "Non-smoker",
        "smoke_social": "Socially",
        
        "pray_regularly": "Regularly",
        "pray_sometimes": "Sometimes",
        "pray_never": "Never",
        
        "fast_always": "Always",
        "fast_sometimes": "Sometimes",
        "fast_no": "No",

        // Profile Score
        "score_title": "Profile Strength",
        "score_subtitle": "Complete your profile to get 10x more matches",
        "score_photo": "Add profile photo",
        "score_bio": "Write a bio",
        "score_religion": "Religion",
        "score_cities": "Origin & Current City",
        "score_lifestyle": "Lifestyle details",
        "score_height": "Add height",
        "score_verified": "Verify your account",
        "score_milestone_50": "Halfway there!",
        "score_milestone_80": "Looking good!",
        "score_milestone_100": "Elite Profile 🔥",

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

        // Legal Onboarding
        "onboarding_legal_title": "Legal Agreement",
        "onboarding_legal_subtitle": "Please review and agree to our terms to continue",
        "onboarding_legal_agree": "I have read and agree to the",
        "onboarding_legal_and": "and",
        "onboarding_legal_button": "I Agree & Continue",

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
        "discover_limit_title": "Daily limit reached",
        "discover_limit_subtitle": "Serious dating takes time. Come back tomorrow for more meaningful matches.",
        "loading_discover": "Finding your spark...",
        "filter_title": "Filter",
        "filter_everyone": "Everyone",
        "filter_men": "Men",
        "filter_women": "Women",

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
        "profile_delete_account": "Delete Account",
        "profile_legal": "Legal",
        "profile_privacy_policy": "Privacy Policy",
        "profile_terms_of_service": "Terms of Service",
        
        "delete_account_title": "Delete Account?",
        "delete_account_message": "This action is permanent and will delete all your data, matches, and messages.",
        "delete_account_confirm": "Delete My Account",

        // Edit profile
        "edit_name": "Name",
        "edit_city": "City",
        "edit_bio": "Bio",
        "edit_name_placeholder": "Your name",
        "edit_city_placeholder": "Your city",
        "edit_bio_placeholder": "Tell people about yourself",
        "edit_bio_smart_title": "Bio Builder",
        "edit_bio_smart_subtitle": "Answer 3 quick questions to generate a bio",
        "edit_bio_q1": "3 words to describe you",
        "edit_bio_q1_placeholder": "e.g. Kind, Ambitious, Funny",
        "edit_bio_q2": "What are you looking for?",
        "edit_bio_q2_placeholder": "e.g. Someone serious for marriage",
        "edit_bio_q3": "A fun fact about you",
        "edit_bio_q3_placeholder": "e.g. I make the best knafeh",
        "edit_bio_generate": "Generate Bio",
        
        "bio_prefix_personality": "I am",
        "bio_prefix_looking": "I'm looking for",
        "bio_prefix_funfact": "Fun fact:",

        "edit_save": "Save Changes",
        "edit_cancel": "Cancel",
        "edit_photo_failed": "Photo upload failed. Saving other changes.",
        "edit_religion": "Religion",
        "edit_interests": "Interests",

        // Report/Block
        "report_title": "Report or Block",
        "report_photos": "Report: Inappropriate photos",
        "report_fake": "Report: Fake profile",
        "report_harassment": "Report: Harassment",
        "block_user": "Block",
        "unmatch_user": "Unmatch",
        "action_cancel": "Cancel",
        "action_delete": "Delete",

        // Marriage Timeline
        "onboarding_marriage_title": "Marriage timeline",
        "onboarding_marriage_subtitle": "What's your goal for this app?",
        "marriage_within_year": "Within a year",
        "marriage_1_2_years": "1-2 years",
        "marriage_2_plus_years": "2+ years",
        "marriage_not_sure": "Not sure yet",

        // Religiosity
        "onboarding_religiosity_title": "How religious are you?",
        "religiosity_secular": "Secular",
        "religiosity_traditional": "Traditional",
        "religiosity_practicing": "Practicing",
        "religiosity_very_practicing": "Very practicing",

        // Education & Profession
        "onboarding_education_title": "What's your education?",
        "onboarding_profession_title": "What's your profession?",
        "onboarding_education_placeholder": "Degree or University",
        "onboarding_profession_placeholder": "Job title",
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
        "phone_subtitle": "أدخل رقم هاتفك للتحقق الآمن",
        "phone_button": "أرسل الرمز",
        "phone_create_account": "جديد في إغنايت؟ أنشئ حساباً",
        "phone_already_have_account": "لديك حساب بالفعل؟ سجل دخولك",
        "phone_change_number": "تغيير رقم الهاتف",
        "otp_subtitle": "أدخل الرمز المكون من ٦ أرقام الذي أرسلناه لهاتفك",
        "otp_button": "تحقق واستمر",

        // Verification
        "verification_title": "توثيق الحساب",
        "verification_subtitle": "أثبت أنك حقيقي واحصل على ثقة أكبر",
        "verification_get_verified": "وثق حسابك",
        "verification_pending_title": "التوثيق قيد المراجعة",
        "verification_pending_subtitle": "نحن نراجع صورتك. يستغرق هذا عادةً ٢٤ ساعة.",
        "verification_step_1": "التقط صورة سيلفي",
        "verification_step_1_desc": "التقط صورة واضحة لنفسك وأنت تنظر للكاميرا",
        "verification_submit": "إرسال للمراجعة",
        "verification_success": "تم الإرسال! سنخطرك بمجرد التوثيق.",

        // Paywall
        "paywall_title": "ترقية إغنايت",
        "paywall_subtitle": "افتح قفل شريك حياتك المثالي",
        "paywall_spark": "سبارك ⚡",
        "paywall_ignite": "إغنايت 🔥",
        "paywall_spark_desc": "إعجابات غير محدودة + ميزات الذكاء الاصطناعي",
        "paywall_ignite_desc": "جميع الميزات + وضع العائلة",
        "paywall_best_value": "أفضل قيمة",
        "paywall_per_month": "شهرياً",
        "paywall_restore": "استعادة المشتريات",
        "paywall_legal": "يتم تجديد الاشتراك تلقائياً كل شهر. يمكنك الإلغاء في أي وقت في إعدادات متجر التطبيقات.",
        "paywall_loading": "جارٍ تحميل الخطط...",
        "paywall_features_title": "الميزات",
        "paywall_feature_likes": "الإعجابات اليومية",
        "paywall_feature_see_likes": "اعرف من أعجب بك",
        "paywall_feature_ai": "توافق الذكاء الاصطناعي",
        "paywall_feature_voice": "المقدمة الصوتية",
        "paywall_feature_boosts": "تعزيزات أسبوعية",
        "paywall_feature_receipts": "تأكيدات القراءة",
        "paywall_feature_family": "وضع العائلة",
        "paywall_feature_priority": "أولوية الظهور",
        "paywall_continue": "متابعة",
        "paywall_retry": "إعادة المحاولة",
        "paywall_features": "الميزات",
        "paywall_free": "مجاني",

        "plan_free": "مجاني",
        "plan_spark": "سبارك",
        "plan_ignite": "إغنايت",
        "common_unlimited": "غير محدود",

        // Rich Profile Fields
        "profile_origin": "الأصل",
        "profile_height": "الطول",
        "profile_smokes": "التدخين",
        "profile_prays": "الصلاة",
        "profile_fasts": "الصيام",
        "profile_about_title": "نبذة عني",
        "profile_basics_title": "الأساسيات",
        "profile_values_title": "القيم والإيمان",
        "profile_lifestyle_title": "نمط الحياة",

        "smoke_yes": "مدخن",
        "smoke_no": "غير مدخن",
        "smoke_social": "في المناسبات",
        
        "pray_regularly": "بانتظام",
        "pray_sometimes": "أحياناً",
        "pray_never": "أبداً",
        
        "fast_always": "دائماً",
        "fast_sometimes": "أحياناً",
        "fast_no": "لا",

        // Profile Score
        "score_title": "قوة الملف الشخصي",
        "score_subtitle": "أكمل ملفك للحصول على توافقات أكثر بـ ١٠ أضعاف",
        "score_photo": "أضف صورة الملف الشخصي",
        "score_bio": "اكتب نبذة عنك",
        "score_religion": "الدين",
        "score_cities": "الأصل والمدينة الحالية",
        "score_lifestyle": "تفاصيل نمط الحياة",
        "score_height": "أضف طولك",
        "score_verified": "وثق حسابك",
        "score_milestone_50": "منتصف الطريق!",
        "score_milestone_80": "تبدو رائعاً!",
        "score_milestone_100": "ملف شخصي نخبة 🔥",

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

        // Legal Onboarding
        "onboarding_legal_title": "الاتفاقية القانونية",
        "onboarding_legal_subtitle": "يرجى مراجعة الموافقة على شروطنا للمتابعة",
        "onboarding_legal_agree": "لقد قرأت وأوافق على",
        "onboarding_legal_and": "و",
        "onboarding_legal_button": "أوافق وأستمر",

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
        "discover_limit_title": "وصلت للحد اليومي",
        "discover_limit_subtitle": "المواعدة الجادة تأخذ وقتاً. عد غداً لمزيد من التوافقات الهادفة.",
        "loading_discover": "جاري البحث عن شرارتك...",
        "filter_title": "تصفية",
        "filter_everyone": "الكل",
        "filter_men": "رجال",
        "filter_women": "نساء",

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
        "profile_delete_account": "حذف الحساب",
        "profile_legal": "قانوني",
        "profile_privacy_policy": "سياسة الخصوصية",
        "profile_terms_of_service": "شروط الخدمة",
        
        "delete_account_title": "حذف الحساب؟",
        "delete_account_message": "هذا الإجراء نهائي وسيؤدي إلى حذف جميع بياناتك وتطابقاتك ورسائلك.",
        "delete_account_confirm": "حذف حسابي",

        // Edit profile
        "edit_name": "الاسم",
        "edit_city": "المدينة",
        "edit_bio": "نبذة عني",
        "edit_name_placeholder": "اسمك",
        "edit_city_placeholder": "مدينتك",
        "edit_bio_placeholder": "أخبر الناس عن نفسك",
        "edit_bio_smart_title": "بناء النبذة",
        "edit_bio_smart_subtitle": "أجب على ٣ أسئلة سريعة لتوليد نبذة تعريفية",
        "edit_bio_q1": "٣ كلمات تصفك",
        "edit_bio_q1_placeholder": "مثلاً: لطيف، طموح، مرح",
        "edit_bio_q2": "ماذا تبحث؟",
        "edit_bio_q2_placeholder": "مثلاً: شخص جاد للزواج",
        "edit_bio_q3": "حقيقة ممتعة عنك",
        "edit_bio_q3_placeholder": "مثلاً: أصنع أفضل كنافة",
        "edit_bio_generate": "توليد النبذة",
        
        "bio_prefix_personality": "أنا",
        "bio_prefix_looking": "أبحث عن",
        "bio_prefix_funfact": "حقيقة ممتعة:",

        "edit_save": "حفظ التغييرات",
        "edit_cancel": "إلغاء",
        "edit_photo_failed": "فشل تحميل الصورة. حفظ التغييرات الأخرى.",
        "edit_religion": "الدين",
        "edit_interests": "الاهتمامات",

        // Report/Block
        "report_title": "إبلاغ أو حظر",
        "report_photos": "إبلاغ: صور غير لائقة",
        "report_fake": "إبلاغ: ملف مزيف",
        "report_harassment": "إبلاغ: مضايقة",
        "block_user": "حظر",
        "unmatch_user": "إلغاء التطابق",
        "action_cancel": "إلغاء",
        "action_delete": "حذف",

        // Marriage Timeline
        "onboarding_marriage_title": "الجدول الزمني للزواج",
        "onboarding_marriage_subtitle": "ما هو هدفك من هذا التطبيق؟",
        "marriage_within_year": "خلال سنة",
        "marriage_1_2_years": "١-٢ سنوات",
        "marriage_2_plus_years": "٢+ سنوات",
        "marriage_not_sure": "لست متأكداً بعد",

        // Religiosity
        "onboarding_religiosity_title": "ما مدى تدينك؟",
        "religiosity_secular": "علماني",
        "religiosity_traditional": "تقليدي",
        "religiosity_practicing": "ملتزم",
        "religiosity_very_practicing": "ملتزم جداً",

        // Education & Profession
        "onboarding_education_title": "ما هو تحصيلك العلمي؟",
        "onboarding_profession_title": "ما هي مهنتك؟",
        "onboarding_education_placeholder": "الدرجة العلمية أو الجامعة",
        "onboarding_profession_placeholder": "المسمى الوظيفي",
    ]
}
