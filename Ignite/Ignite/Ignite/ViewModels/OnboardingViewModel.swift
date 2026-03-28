import Foundation
import SwiftUI
import PhotosUI
import Combine
import FirebaseAuth

class OnboardingViewModel: ObservableObject {
    @Published var step: Int = 0
    let totalSteps = 6

    @Published var birthday: Date = Calendar.current.date(byAdding: .year, value: -22, to: Date()) ?? Date()
    @Published var gender: String = ""
    @Published var city: String = ""
    @Published var selectedInterests: Set<String> = []
    @Published var religion: String = ""
    @Published var bio: String = ""
    @Published var selectedPhoto: PhotosPickerItem? = nil
    @Published var profileImage: UIImage? = nil
    @Published var isUploading: Bool = false

    var genderOptions: [String] { [L("gender_man"), L("gender_woman"), L("gender_nonbinary")] }

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
                    self.profileImage = image
                }
            }
        }
    }

    func uploadPhotoAndComplete(authViewModel: AuthViewModel) {
        isUploading = true

        guard let image = profileImage else {
            buildAndSaveUser(authViewModel: authViewModel, imageURL: "")
            return
        }

        Task {
            do {
                let url = try await CloudinaryService.uploadImage(image)
                await MainActor.run {
                    buildAndSaveUser(authViewModel: authViewModel, imageURL: url)
                }
            } catch {
                await MainActor.run {
                    buildAndSaveUser(authViewModel: authViewModel, imageURL: "")
                }
            }
        }
    }

    private func buildAndSaveUser(authViewModel: AuthViewModel, imageURL: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let user = User(
            id: uid,
            name: authViewModel.currentUser?.name ?? "",
            age: age,
            bio: bio,
            city: city,
            gender: gender,
            interestedIn: interestedIn,
            profileImageURL: imageURL,
            interests: Array(selectedInterests),
            religion: religion
        )
        authViewModel.currentUser = user
        authViewModel.completeOnboarding()
        isUploading = false
    }
}
