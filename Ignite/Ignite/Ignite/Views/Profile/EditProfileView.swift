import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var bio = ""
    @State private var city = ""
    @State private var religion = ""
    @State private var selectedInterests: Set<String> = []

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var isUploading = false
    @State private var errorMessage = ""

    private let religionOptions: [(category: String, options: [String])] = [
        ("Muslim", ["Sunni Muslim", "Shia Muslim"]),
        ("Christian", ["Greek Orthodox", "Greek Catholic (Melkite)", "Roman Catholic", "Maronite", "Evangelical", "Baptist"]),
        ("Druze", ["Druze"]),
        ("Other", ["Secular", "Prefer not to say"])
    ]

    private let interestOptions = [
        "Travel", "Food", "Music", "Art", "Sports",
        "Reading", "Movies", "Cooking", "Photography", "Gaming",
        "Fitness", "Dancing", "Coffee", "Nature", "Tech"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Photo
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            Group {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                } else if let url = authViewModel.currentUser?.profileImageURL,
                                          !url.isEmpty {
                                    AsyncImage(url: URL(string: url)) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.orange.opacity(0.2)
                                    }
                                } else {
                                    Color.orange.opacity(0.15)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.orange)
                                }
                            }
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())

                            Image(systemName: "camera.fill")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(7)
                                .background(IgniteTheme.primary)
                                .clipShape(Circle())
                                .offset(x: 4, y: 4)
                        }
                    }
                    .onChange(of: selectedPhoto) { _, _ in
                        Task {
                            if let item = selectedPhoto,
                               let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                await MainActor.run { profileImage = image }
                            }
                        }
                    }
                    .padding(.top, 8)

                    // Basic fields
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L("edit_name")).font(.caption.bold()).foregroundColor(IgniteTheme.textSecondary)
                            TextField(L("edit_name_placeholder"), text: $name).inputField()
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L("edit_city")).font(.caption.bold()).foregroundColor(IgniteTheme.textSecondary)
                            TextField(L("edit_city_placeholder"), text: $city).inputField()
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L("edit_bio")).font(.caption.bold()).foregroundColor(IgniteTheme.textSecondary)
                            TextField(L("edit_bio_placeholder"), text: $bio, axis: .vertical)
                                .lineLimit(3...5)
                                .inputField()
                        }
                    }
                    .padding(.horizontal)

                    // Religion
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L("edit_religion"))
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(religionOptions, id: \.category) { group in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(group.category)
                                    .font(.caption.bold())
                                    .foregroundColor(IgniteTheme.textSecondary)
                                    .textCase(.uppercase)
                                    .padding(.horizontal)

                                ForEach(group.options, id: \.self) { option in
                                    SelectionRow(
                                        title: option,
                                        isSelected: religion == option
                                    ) {
                                        religion = option
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }

                    // Interests
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L("edit_interests"))
                            .font(.headline)
                            .padding(.horizontal)

                        InterestTagGrid(
                            options: interestOptions,
                            selected: selectedInterests
                        ) { interest in
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    // Save
                    Button {
                        save()
                    } label: {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(IgniteTheme.mainGradient)
                                .cornerRadius(IgniteTheme.buttonRadius)
                        } else {
                            Text(L("edit_save"))
                                .primaryButton()
                        }
                    }
                    .disabled(isUploading || name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("edit_cancel")) { dismiss() }
                }
            }
            .onAppear { loadCurrentUser() }
        }
    }

    private func loadCurrentUser() {
        guard let user = authViewModel.currentUser else { return }
        name = user.name
        bio = user.bio
        city = user.city
        religion = user.religion ?? ""
        selectedInterests = Set(user.interests)
    }

    private func save() {
        guard var user = authViewModel.currentUser else { return }
        isUploading = true
        errorMessage = ""

        user.name = name.trimmingCharacters(in: .whitespaces)
        user.bio = bio.trimmingCharacters(in: .whitespaces)
        user.city = city.trimmingCharacters(in: .whitespaces)
        user.religion = religion.isEmpty ? nil : religion
        user.interests = Array(selectedInterests)

        if let newImage = profileImage {
            Task {
                do {
                    let url = try await CloudinaryService.uploadImage(newImage)
                    await MainActor.run {
                        user.profileImageURL = url
                        authViewModel.updateUser(user)
                        isUploading = false
                        dismiss()
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Photo upload failed. Saving other changes."
                        authViewModel.updateUser(user)
                        isUploading = false
                        dismiss()
                    }
                }
            }
        } else {
            authViewModel.updateUser(user)
            isUploading = false
            dismiss()
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
