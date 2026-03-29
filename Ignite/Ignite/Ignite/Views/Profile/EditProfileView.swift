import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var bio = ""
    @State private var bioPersonality = ""
    @State private var bioLookingFor = ""
    @State private var bioFunFact = ""
    @State private var showSmartBio = false
    @State private var city = ""
    @State private var originCity = ""
    @State private var height = 170
    @State private var religion = ""
    @State private var religiosityLevel = ""
    @State private var marriageTimeline = ""
    @State private var education = ""
    @State private var profession = ""
    @State private var smokes = ""
    @State private var prays = ""
    @State private var fasts = ""
    @State private var selectedInterests: Set<String> = []

    @State private var imageURLs: [String] = []
    @State private var newImages: [UIImage] = []
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var isUploading = false
    @State private var errorMessage = ""

    private let religionOptions: [(category: String, options: [String])] = [
        (L("religion_cat_muslim"), [L("religion_sunni"), L("religion_shia")]),
        (L("religion_cat_christian"), [L("religion_orthodox"), L("religion_melkite"), L("religion_catholic"), L("religion_maronite"), L("religion_evangelical"), L("religion_baptist")]),
        (L("religion_cat_druze"), [L("religion_druze")]),
        (L("religion_cat_other"), [L("religion_secular"), L("religion_prefer_not")])
    ]

    private let interestOptions = [
        L("interest_travel"), L("interest_food"), L("interest_music"), L("interest_art"), L("interest_sports"),
        L("interest_reading"), L("interest_movies"), L("interest_cooking"), L("interest_photography"), L("interest_gaming"),
        L("interest_fitness"), L("interest_dancing"), L("interest_coffee"), L("interest_nature"), L("interest_tech")
    ]
    
    private let marriageOptions = [
        L("marriage_within_year"), L("marriage_1_2_years"), L("marriage_2_plus_years"), L("marriage_not_sure")
    ]
    
    private let religiosityOptions = [
        L("religiosity_secular"), L("religiosity_traditional"), L("religiosity_practicing"), L("religiosity_very_practicing")
    ]
    
    private let smokeOptions = [L("smoke_yes"), L("smoke_no"), L("smoke_social")]
    private let prayOptions = [L("pray_regularly"), L("pray_sometimes"), L("pray_never")]
    private let fastOptions = [L("fast_always"), L("fast_sometimes"), L("fast_no")]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // 1. Photo Grid Editor
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L("onboarding_photo_title"))
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            // Existing Remote Images
                            ForEach(imageURLs, id: \.self) { url in
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: URL(string: url)) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button { imageURLs.removeAll { $0 == url } } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)
                                            .padding(4)
                                    }
                                }
                            }
                            
                            // New Local Images
                            ForEach(0..<newImages.count, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: newImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button { newImages.remove(at: index) } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)
                                            .padding(4)
                                    }
                                }
                            }
                            
                            // Empty Slots
                            if (imageURLs.count + newImages.count) < 5 {
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .frame(height: 120)
                                        .overlay(Image(systemName: "plus").foregroundColor(IgniteTheme.primary))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: selectedPhoto) { _, _ in loadNewPhoto() }
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
                            Text(L("profile_origin")).font(.caption.bold()).foregroundColor(IgniteTheme.textSecondary)
                            TextField(L("onboarding_city_placeholder"), text: $originCity).inputField()
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L("profile_height")).font(.caption.bold()).foregroundColor(IgniteTheme.textSecondary)
                            HStack {
                                Picker("", selection: $height) {
                                    ForEach(140...210, id: \.self) { val in
                                        Text("\(val) cm").tag(val)
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(IgniteTheme.primary)
                                Spacer()
                            }
                            .inputField()
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L("onboarding_education_title")).font(.caption.bold()).foregroundColor(IgniteTheme.textSecondary)
                            TextField(L("onboarding_education_placeholder"), text: $education).inputField()
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L("onboarding_profession_title")).font(.caption.bold()).foregroundColor(IgniteTheme.textSecondary)
                            TextField(L("onboarding_profession_placeholder"), text: $profession).inputField()
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(L("edit_bio")).font(.caption.bold()).foregroundColor(IgniteTheme.textSecondary)
                                Spacer()
                                Button {
                                    withAnimation { showSmartBio.toggle() }
                                } label: {
                                    Text(L("edit_bio_smart_title"))
                                        .font(.caption.bold())
                                        .foregroundColor(IgniteTheme.primary)
                                }
                            }
                            
                            if showSmartBio {
                                VStack(alignment: .leading, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(L("edit_bio_q1")).font(.caption2.bold()).foregroundColor(.secondary)
                                        TextField(L("edit_bio_q1_placeholder"), text: $bioPersonality)
                                            .inputField()
                                    }
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(L("edit_bio_q2")).font(.caption2.bold()).foregroundColor(.secondary)
                                        TextField(L("edit_bio_q2_placeholder"), text: $bioLookingFor)
                                            .inputField()
                                    }
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(L("edit_bio_q3")).font(.caption2.bold()).foregroundColor(.secondary)
                                        TextField(L("edit_bio_q3_placeholder"), text: $bioFunFact)
                                            .inputField()
                                    }
                                    
                                    Button {
                                        generateBio()
                                    } label: {
                                        Text(L("edit_bio_generate"))
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(IgniteTheme.mainGradient)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                                .padding(.bottom, 8)
                            }

                            TextField(L("edit_bio_placeholder"), text: $bio, axis: .vertical)
                                .lineLimit(3...5)
                                .inputField()
                        }
                    }
                    .padding(.horizontal)

                    // Marriage Timeline
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L("onboarding_marriage_title")).font(.headline).padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(marriageOptions, id: \.self) { opt in
                                    Text(opt)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(marriageTimeline == opt ? IgniteTheme.primary : Color(.systemGray6))
                                        .foregroundColor(marriageTimeline == opt ? .white : .primary)
                                        .cornerRadius(20)
                                        .onTapGesture { marriageTimeline = opt }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Religiosity
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L("onboarding_religiosity_title")).font(.headline).padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(religiosityOptions, id: \.self) { opt in
                                    Text(opt)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(religiosityLevel == opt ? IgniteTheme.primary : Color(.systemGray6))
                                        .foregroundColor(religiosityLevel == opt ? .white : .primary)
                                        .cornerRadius(20)
                                        .onTapGesture { religiosityLevel = opt }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Lifestyle (Smoking/Praying/Fasting)
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L("profile_lifestyle_title")).font(.headline).padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L("profile_smokes")).font(.subheadline.bold()).padding(.horizontal)
                            segmentPicker(options: smokeOptions, selection: $smokes)
                            
                            Text(L("profile_prays")).font(.subheadline.bold()).padding(.horizontal)
                            segmentPicker(options: prayOptions, selection: $prays)
                            
                            Text(L("profile_fasts")).font(.subheadline.bold()).padding(.horizontal)
                            segmentPicker(options: fastOptions, selection: $fasts)
                        }
                    }

                    // Religion
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L("edit_religion"))
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(religionOptions, id: \.category) { group in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(group.category)
                                        .font(.caption.bold())
                                        .foregroundColor(IgniteTheme.textSecondary)
                                        .textCase(.uppercase)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(group.options, id: \.self) { option in
                                                Text(option)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(religion == option ? IgniteTheme.primary : Color(.systemGray6))
                                                    .foregroundColor(religion == option ? .white : .primary)
                                                    .cornerRadius(20)
                                                    .onTapGesture { religion = option }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
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
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .navigationTitle(L("profile_edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L("edit_cancel")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        save()
                    } label: {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text(L("edit_save")).bold()
                        }
                    }
                    .disabled(isUploading)
                }
            }
            .onAppear { loadCurrentUser() }
        }
    }

    @ViewBuilder
    private func segmentPicker(options: [String], selection: Binding<String>) -> some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { opt in
                Button {
                    selection.wrappedValue = opt
                } label: {
                    Text(opt)
                        .font(.caption.bold())
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(selection.wrappedValue == opt ? IgniteTheme.primary : Color(.systemGray6))
                        .foregroundColor(selection.wrappedValue == opt ? .white : .primary)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }

    private func loadNewPhoto() {
        Task {
            if let item = selectedPhoto,
               let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    if (self.imageURLs.count + self.newImages.count) < 5 {
                        self.newImages.append(image)
                    }
                    self.selectedPhoto = nil
                }
            }
        }
    }

    private func loadCurrentUser() {
        guard let user = authViewModel.currentUser else { return }
        name = user.name
        bio = user.bio
        city = user.city
        imageURLs = user.imageURLs
        originCity = user.originCity ?? ""
        height = user.height ?? 170
        religion = user.religion ?? ""
        religiosityLevel = user.religiosityLevel ?? ""
        marriageTimeline = user.marriageTimeline ?? ""
        education = user.education ?? ""
        profession = user.profession ?? ""
        smokes = user.smokes ?? ""
        prays = user.prays ?? ""
        fasts = user.fasts ?? ""
        selectedInterests = Set(user.interests)
    }

    private func generateBio() {
        var parts: [String] = []
        if !bioPersonality.isEmpty { parts.append("\(L("bio_prefix_personality")) \(bioPersonality)") }
        if !bioLookingFor.isEmpty { parts.append("\(L("bio_prefix_looking")) \(bioLookingFor)") }
        if !bioFunFact.isEmpty { parts.append("\(L("bio_prefix_funfact")) \(bioFunFact)") }
        
        if !parts.isEmpty {
            let combined = parts.joined(separator: ". ") + "."
            withAnimation {
                bio = combined
                showSmartBio = false
            }
        }
    }

    private func save() {
        guard var user = authViewModel.currentUser else { return }
        isUploading = true
        errorMessage = ""

        user.name = name.trimmingCharacters(in: .whitespaces)
        user.bio = bio.trimmingCharacters(in: .whitespaces)
        user.city = city.trimmingCharacters(in: .whitespaces)
        user.imageURLs = imageURLs
        user.originCity = originCity.trimmingCharacters(in: .whitespaces)
        user.height = height
        user.religion = religion.isEmpty ? nil : religion
        user.religiosityLevel = religiosityLevel.isEmpty ? nil : religiosityLevel
        user.marriageTimeline = marriageTimeline.isEmpty ? nil : marriageTimeline
        user.education = education.isEmpty ? nil : education
        user.profession = profession.isEmpty ? nil : profession
        user.smokes = smokes.isEmpty ? nil : smokes
        user.prays = prays.isEmpty ? nil : prays
        user.fasts = fasts.isEmpty ? nil : fasts
        user.interests = Array(selectedInterests)

        Task {
            do {
                var finalURLs = imageURLs
                for img in newImages {
                    let url = try await CloudinaryService.uploadImage(img)
                    finalURLs.append(url)
                }
                user.imageURLs = finalURLs
                
                await MainActor.run {
                    authViewModel.updateUser(user)
                    isUploading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    errorMessage = L("edit_photo_failed")
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
