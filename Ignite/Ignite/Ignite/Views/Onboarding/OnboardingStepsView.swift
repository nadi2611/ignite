import SwiftUI
import PhotosUI

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
                    in: ...Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
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

// MARK: - Step 3: Interested In

// MARK: - Step 4: City

struct OnboardingCityView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_city_title"),
            subtitle: L("onboarding_city_subtitle"),
            vm: vm,
            canContinue: !vm.city.trimmingCharacters(in: .whitespaces).isEmpty
        ) {
            TextField(L("onboarding_city_placeholder"), text: $vm.city)
                .inputField()
        }
    }
}

// MARK: - Step 5: Religion

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

// MARK: - Step 6: Interests

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

    var body: some View {
        OnboardingStepWrapper(
            title: L("onboarding_photo_title"),
            subtitle: L("onboarding_photo_subtitle"),
            vm: vm,
            canContinue: true,
            isLastStep: true
        ) {
            VStack(spacing: 24) {
                PhotosPicker(selection: $vm.selectedPhoto, matching: .images) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                            .frame(width: 220, height: 280)

                        if let image = vm.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 220, height: 280)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(IgniteTheme.primary)
                                Text(L("onboarding_photo_tap"))
                                    .foregroundColor(IgniteTheme.textSecondary)
                                    .font(.subheadline)
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
