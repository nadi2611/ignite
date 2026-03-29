import SwiftUI
import PhotosUI

// MARK: - Step 0: Legal Agreement

struct OnboardingLegalView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showPrivacy = false
    @State private var showTerms = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(IgniteTheme.mainGradient)
            
            VStack(spacing: 12) {
                Text(L("onboarding_legal_title"))
                    .font(.title.bold())
                Text(L("onboarding_legal_subtitle"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: 12) {
                    Button {
                        vm.agreedToTerms.toggle()
                    } label: {
                        Image(systemName: vm.agreedToTerms ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(vm.agreedToTerms ? IgniteTheme.primary : .secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L("onboarding_legal_agree"))
                            .font(.subheadline)
                            .foregroundColor(IgniteTheme.textPrimary)
                        
                        HStack(spacing: 4) {
                            Button(L("profile_privacy_policy")) { showPrivacy = true }
                                .font(.subheadline.bold())
                                .foregroundColor(IgniteTheme.primary)
                            
                            Text(L("onboarding_legal_and"))
                                .font(.subheadline)
                            
                            Button(L("profile_terms_of_service")) { showTerms = true }
                                .font(.subheadline.bold())
                                .foregroundColor(IgniteTheme.primary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Button {
                    vm.next()
                } label: {
                    Text(L("onboarding_legal_button"))
                        .primaryButton()
                }
                .disabled(!vm.agreedToTerms)
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 48)
        }
        .sheet(isPresented: $showPrivacy) {
            LocalLegalView(filename: "privacy", title: L("profile_privacy_policy"))
        }
        .sheet(isPresented: $showTerms) {
            LocalLegalView(filename: "terms", title: L("profile_terms_of_service"))
        }
    }
}

// MARK: - Step 1: Birthday

struct OnboardingBirthdayView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_birthday_title"),
            subtitle: L("onboarding_birthday_subtitle"),
            vm: vm
        ) {
            VStack(spacing: 24) {
                DatePicker(
                    "",
                    selection: $vm.birthday,
                    in: ...(Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                Text("\(L("onboarding_birthday_age")): \(vm.age)")
                    .font(.title2.bold())
                    .foregroundColor(IgniteTheme.primary)
            }
        }
    }
}

// MARK: - Step 2: Gender

struct OnboardingGenderView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_gender_title"),
            subtitle: L("onboarding_gender_subtitle"),
            vm: vm,
            canContinue: !vm.gender.isEmpty
        ) {
            VStack(spacing: 14) {
                ForEach(vm.genderOptions, id: \.self) { option in
                    SelectionRow(
                        title: option,
                        isSelected: vm.gender == option
                    ) {
                        vm.gender = option
                    }
                }
            }
        }
    }
}

// MARK: - Step 3: Origin City

struct OnboardingOriginView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("profile_origin"),
            subtitle: L("onboarding_city_subtitle"),
            vm: vm,
            canContinue: !vm.originCity.trimmingCharacters(in: .whitespaces).isEmpty
        ) {
            VStack(alignment: .leading, spacing: 12) {
                TextField(L("onboarding_city_placeholder"), text: $vm.originCity)
                    .inputField()
                
                if !vm.filteredOriginCities.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(vm.filteredOriginCities, id: \.self) { city in
                                Button {
                                    vm.originCity = city
                                    vm.next()
                                } label: {
                                    HStack {
                                        Text(city)
                                            .foregroundColor(IgniteTheme.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(IgniteTheme.textSecondary)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                }
                                Divider()
                            }
                        }
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
    }
}

// MARK: - Step 4: Height

struct OnboardingHeightView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("profile_height"),
            subtitle: "",
            vm: vm
        ) {
            VStack(spacing: 24) {
                Picker("", selection: $vm.height) {
                    ForEach(140...210, id: \.self) { val in
                        Text("\(val) cm").tag(val)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                
                Text("\(vm.height) cm")
                    .font(.title2.bold())
                    .foregroundColor(IgniteTheme.primary)
            }
        }
    }
}

// MARK: - Step 5: City

struct OnboardingCityView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_city_title"),
            subtitle: L("onboarding_city_subtitle"),
            vm: vm,
            canContinue: !vm.city.trimmingCharacters(in: .whitespaces).isEmpty
        ) {
            VStack(alignment: .leading, spacing: 12) {
                TextField(L("onboarding_city_placeholder"), text: $vm.city)
                    .inputField()
                
                if !vm.filteredCurrentCities.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(vm.filteredCurrentCities, id: \.self) { city in
                                Button {
                                    vm.city = city
                                    vm.next()
                                } label: {
                                    HStack {
                                        Text(city)
                                            .foregroundColor(IgniteTheme.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(IgniteTheme.textSecondary)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                }
                                Divider()
                            }
                        }
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
    }
}

// MARK: - Step 6: Religion

struct OnboardingReligionView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_religion_title"),
            subtitle: L("onboarding_religion_subtitle"),
            vm: vm,
            canContinue: !vm.religion.isEmpty
        ) {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(vm.religionOptions, id: \.category) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(group.category)
                            .font(.caption.bold())
                            .foregroundColor(IgniteTheme.textSecondary)
                            .textCase(.uppercase)
                            .padding(.leading, 4)

                        ForEach(group.options, id: \.self) { option in
                            SelectionRow(
                                title: option,
                                isSelected: vm.religion == option
                            ) {
                                vm.religion = option
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Step 6: Religiosity

struct OnboardingReligiosityView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_religiosity_title"),
            subtitle: "",
            vm: vm,
            canContinue: !vm.religiosityLevel.isEmpty
        ) {
            VStack(spacing: 14) {
                ForEach(vm.religiosityOptions, id: \.self) { option in
                    SelectionRow(
                        title: option,
                        isSelected: vm.religiosityLevel == option
                    ) {
                        vm.religiosityLevel = option
                    }
                }
            }
        }
    }
}

// MARK: - Step 8: Marriage Timeline

struct OnboardingMarriageView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_marriage_title"),
            subtitle: L("onboarding_marriage_subtitle"),
            vm: vm,
            canContinue: !vm.marriageTimeline.isEmpty
        ) {
            VStack(spacing: 14) {
                ForEach(vm.marriageTimelineOptions, id: \.self) { option in
                    SelectionRow(
                        title: option,
                        isSelected: vm.marriageTimeline == option
                    ) {
                        vm.marriageTimeline = option
                    }
                }
            }
        }
    }
}

// MARK: - Step 9: Education & Profession

struct OnboardingEducationView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_education_title"),
            subtitle: "",
            vm: vm,
            canContinue: !vm.education.isEmpty && !vm.profession.isEmpty
        ) {
            VStack(spacing: 20) {
                TextField(L("onboarding_education_placeholder"), text: $vm.education)
                    .inputField()
                
                TextField(L("onboarding_profession_placeholder"), text: $vm.profession)
                    .inputField()
            }
        }
    }
}

// MARK: - Step 10: Smokes

struct OnboardingSmokesView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("profile_smokes"),
            subtitle: "",
            vm: vm,
            canContinue: !vm.smokes.isEmpty
        ) {
            VStack(spacing: 14) {
                ForEach(vm.smokeOptions, id: \.self) { option in
                    SelectionRow(title: option, isSelected: vm.smokes == option) {
                        vm.smokes = option
                    }
                }
            }
        }
    }
}

// MARK: - Step 11: Prays

struct OnboardingPraysView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("profile_prays"),
            subtitle: "",
            vm: vm,
            canContinue: !vm.prays.isEmpty
        ) {
            VStack(spacing: 14) {
                ForEach(vm.prayOptions, id: \.self) { option in
                    SelectionRow(title: option, isSelected: vm.prays == option) {
                        vm.prays = option
                    }
                }
            }
        }
    }
}

// MARK: - Step 12: Fasts

struct OnboardingFastsView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("profile_fasts"),
            subtitle: "",
            vm: vm,
            canContinue: !vm.fasts.isEmpty
        ) {
            VStack(spacing: 14) {
                ForEach(vm.fastOptions, id: \.self) { option in
                    SelectionRow(title: option, isSelected: vm.fasts == option) {
                        vm.fasts = option
                    }
                }
            }
        }
    }
}

// MARK: - Step 13: Interests

struct OnboardingInterestsView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_interests_title"),
            subtitle: L("onboarding_interests_subtitle"),
            vm: vm,
            canContinue: vm.selectedInterests.count >= 3
        ) {
            InterestTagGrid(
                options: vm.interestOptions,
                selected: vm.selectedInterests
            ) { interest in
                vm.toggleInterest(interest)
            }
        }
    }
}

// MARK: - Step 6: Photo

struct OnboardingPhotoView: View {
    @ObservedObject var vm: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_photo_title"),
            subtitle: L("onboarding_photo_subtitle"),
            vm: vm,
            canContinue: !vm.profileImages.isEmpty,
            isLastStep: true
        ) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    if index < vm.profileImages.count {
                        // Displayed Photo
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: vm.profileImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            Button {
                                vm.profileImages.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                    .padding(8)
                            }
                        }
                    } else if index < 5 {
                        // Empty Slot
                        PhotosPicker(selection: $vm.selectedPhoto, matching: .images) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .frame(height: 180)
                                .overlay(
                                    Image(systemName: index == 0 ? "camera.fill" : "plus")
                                        .font(.title)
                                        .foregroundColor(IgniteTheme.primary)
                                )
                        }
                    }
                }
            }
            .onChange(of: vm.selectedPhoto) { _, _ in
                vm.loadPhoto()
            }
        }
    }
}

// MARK: - Reusable components

struct OnboardingStepWrapper<Content: View>: View {
    let title: String
    let subtitle: String
    @ObservedObject var vm: OnboardingViewModel
    var canContinue: Bool = true
    var isLastStep: Bool = false
    @ViewBuilder let content: () -> Content
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(IgniteTheme.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(IgniteTheme.textSecondary)
            }
            .padding(.horizontal)
            .padding(.top, 32)
            .padding(.bottom, 32)

            ScrollView {
                content()
                    .padding(.horizontal)
            }

            Spacer()

            Button {
                if isLastStep {
                    vm.uploadPhotoAndComplete(authViewModel: authViewModel)
                } else {
                    vm.next()
                }
            } label: {
                if vm.isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(IgniteTheme.mainGradient)
                        .cornerRadius(IgniteTheme.buttonRadius)
                } else {
                    Text(isLastStep ? L("onboarding_finish") : L("onboarding_continue"))
                        .primaryButton()
                }
            }
            .disabled(!canContinue || vm.isUploading)
            .opacity(canContinue ? 1 : 0.5)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

struct SelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(isSelected ? .white : IgniteTheme.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.body.bold())
                }
            }
            .padding(16)
            .background(isSelected ? IgniteTheme.mainGradient : LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(14)
        }
    }
}

struct InterestTagGrid: View {
    let options: [String]
    let selected: Set<String>
    let onTap: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button {
                    onTap(option)
                } label: {
                    Text(option)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(selected.contains(option) ? .white : IgniteTheme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            selected.contains(option)
                                ? IgniteTheme.mainGradient
                                : LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(20)
                }
            }
        }
    }
}
