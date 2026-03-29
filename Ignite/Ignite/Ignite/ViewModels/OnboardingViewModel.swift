import Foundation
import SwiftUI
import PhotosUI
import Combine
import FirebaseAuth

class OnboardingViewModel: ObservableObject {
    @Published var step: Int = 0
    let totalSteps = 13

    @Published var birthday: Date = Calendar.current.date(byAdding: .year, value: -22, to: Date()) ?? Date()
    @Published var gender: String = ""
    @Published var agreedToTerms: Bool = false
    @Published var city: String = ""
    @Published var originCity: String = ""
    @Published var height: Int = 170
    @Published var smokes: String = ""
    @Published var prays: String = ""
    @Published var fasts: String = ""
    @Published var selectedInterests: Set<String> = []
    @Published var religion: String = ""
    @Published var religiosityLevel: String = ""
    @Published var marriageTimeline: String = ""
    @Published var education: String = ""
    @Published var profession: String = ""
    @Published var bio: String = ""
    @Published var bioPersonality: String = ""
    @Published var bioLookingFor: String = ""
    @Published var bioFunFact: String = ""
    @Published var selectedPhoto: PhotosPickerItem? = nil
    @Published var profileImages: [UIImage] = []
    @Published var isUploading: Bool = false

    let israelCities: [String] = [
        "Nazareth", "Haifa", "Acre", "Jerusalem", "Tel Aviv", "Jaffa", "Umm al-Fahm", "Rahat", "Tayibe", "Shefa-Amr",
        "Baqa al-Gharbiyye", "Tamra", "Sakhnin", "Tira", "Arraba", "Maghar", "Kafr Qasim", "Kafr Qara", "Daliat al-Karmel",
        "Yafa an-Naseriyye", "Reineh", "Iksal", "Tur'an", "Ein Mahil", "Kafr Kanna", "Mashhad", "Daburiyya", "Shibli-Umm al-Ghanam",
        "Basmat Tab'un", "Zarzir", "Bir al-Maksur", "Kaukab abu al-Hija", "Jadeidi-Makr", "Mazra'a", "Abu Snan", "Sheikh Danun",
        "Kafr Yasif", "Yirka", "Julis", "Hurfeish", "Beit Jann", "Peki'in", "Rameh", "Sajur", "Nahf", "Deir al-Asad", "Bi'ina",
        "Majd al-Krum", "Kabul", "Sha'ab", "I'billin", "Kfar Manda", "Bir al-Sabi", "Hura", "Kuseife", "Lakiya", "Segev Shalom",
        "Tel Sheva", "Ar'ara ba-Negev", "Lod", "Ramla", "Nazareth Illit", "Karmiel", "Ma'alot-Tarshiha", "Safed", "Tiberias",
        "Beit She'an", "Afula", "Hadera", "Netanya", "Herzliya", "Ramat Gan", "Holon", "Bat Yam", "Ashdod", "Ashkelon", "Eilat"
    ]

    var filteredOriginCities: [String] {
        if originCity.isEmpty { return [] }
        return israelCities.filter { $0.lowercased().contains(originCity.lowercased()) && $0 != originCity }
    }

    var filteredCurrentCities: [String] {
        if city.isEmpty { return [] }
        return israelCities.filter { $0.lowercased().contains(city.lowercased()) && $0 != city }
    }

    var genderOptions: [String] { [L("gender_man"), L("gender_woman"), L("gender_nonbinary")] }

    var marriageTimelineOptions: [String] {[
        L("marriage_within_year"), L("marriage_1_2_years"), L("marriage_2_plus_years"), L("marriage_not_sure")
    ]}

    var religiosityOptions: [String] {[
        L("religiosity_secular"), L("religiosity_traditional"), L("religiosity_practicing"), L("religiosity_very_practicing")
    ]}
    
    var smokeOptions: [String] {[
        L("smoke_yes"), L("smoke_no"), L("smoke_social")
    ]}
    
    var prayOptions: [String] {[
        L("pray_regularly"), L("pray_sometimes"), L("pray_never")
    ]}
    
    var fastOptions: [String] {[
        L("fast_always"), L("fast_sometimes"), L("fast_no")
    ]}

    var interestedIn: String {
        switch gender {
        case "Man": return "Women"
        case "Woman": return "Men"
        default: return "Everyone"
        }
    }
    var interestOptions: [String] {[
        L("interest_travel"), L("interest_food"), L("interest_music"), L("interest_art"), L("interest_sports"),
        L("interest_reading"), L("interest_movies"), L("interest_cooking"), L("interest_photography"), L("interest_gaming"),
        L("interest_fitness"), L("interest_dancing"), L("interest_coffee"), L("interest_nature"), L("interest_tech")
    ]}

    var religionOptions: [(category: String, options: [String])] {[
        (L("religion_cat_muslim"), [L("religion_sunni"), L("religion_shia")]),
        (L("religion_cat_christian"), [L("religion_orthodox"), L("religion_melkite"), L("religion_catholic"), L("religion_maronite"), L("religion_evangelical"), L("religion_baptist")]),
        (L("religion_cat_druze"), [L("religion_druze")]),
        (L("religion_cat_other"), [L("religion_secular"), L("religion_prefer_not")])
    ]}

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
    }

    var progress: CGFloat {
        CGFloat(step) / CGFloat(totalSteps)
    }

    func next() {
        if step < totalSteps { step += 1 }
    }

    func back() {
        if step > 0 { step -= 1 }
    }

    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    func loadPhoto() {
        Task {
            if let item = selectedPhoto,
               let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    if self.profileImages.count < 5 {
                        self.profileImages.append(image)
                    }
                    self.selectedPhoto = nil
                }
            }
        }
    }

    func uploadPhotoAndComplete(authViewModel: AuthViewModel) {
        isUploading = true

        if profileImages.isEmpty {
            buildAndSaveUser(authViewModel: authViewModel, imageURLs: [])
            return
        }

        Task {
            var uploadedURLs: [String] = []
            for image in profileImages {
                if let url = try? await CloudinaryService.uploadImage(image) {
                    uploadedURLs.append(url)
                }
            }
            
            await MainActor.run {
                buildAndSaveUser(authViewModel: authViewModel, imageURLs: uploadedURLs)
            }
        }
    }

    private func buildAndSaveUser(authViewModel: AuthViewModel, imageURLs: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let user = User(
            id: uid,
            name: authViewModel.currentUser?.name ?? "",
            age: age,
            bio: bio,
            city: city,
            gender: gender,
            interestedIn: interestedIn,
            imageURLs: imageURLs,
            verificationSelfieURL: nil,
            interests: Array(selectedInterests),
            religion: religion,
            religiosityLevel: religiosityLevel,
            marriageTimeline: marriageTimeline,
            education: education,
            profession: profession,
            phoneNumber: authViewModel.currentUser?.phoneNumber,
            originCity: originCity,
            height: height,
            smokes: smokes,
            prays: prays,
            fasts: fasts,
            isVerified: false,
            isPendingVerification: false,
            isAdmin: false,
            agreedToTerms: agreedToTerms,
            agreedAt: Date(),
            swipesToday: 0,
            lastSwipeDate: nil,
            createdAt: Date()
        )
        authViewModel.updateUser(user)
        authViewModel.completeOnboarding()
        isUploading = false
    }
}
