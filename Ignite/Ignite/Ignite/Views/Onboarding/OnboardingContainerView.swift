import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            VStack(spacing: 16) {
                HStack {
                    if vm.step > 0 {
                        Button { vm.back() } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(IgniteTheme.textPrimary)
                        }
                    }
                    Spacer()
                    Text("\(vm.step + 1) of \(vm.totalSteps)")
                        .font(.caption)
                        .foregroundColor(IgniteTheme.textSecondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(IgniteTheme.mainGradient)
                            .frame(width: geo.size.width * vm.progress, height: 4)
                            .animation(.spring(), value: vm.progress)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // Steps
            Group {
                switch vm.step {
                case 0: OnboardingLegalView(vm: vm)
                case 1: OnboardingBirthdayView(vm: vm)
                case 2: OnboardingGenderView(vm: vm)
                case 3: OnboardingOriginView(vm: vm)
                case 4: OnboardingHeightView(vm: vm)
                case 5: OnboardingReligionView(vm: vm)
                case 6: OnboardingReligiosityView(vm: vm)
                case 7: OnboardingMarriageView(vm: vm)
                case 8: OnboardingEducationView(vm: vm)
                case 9: OnboardingSmokesView(vm: vm)
                case 10: OnboardingPraysView(vm: vm)
                case 11: OnboardingFastsView(vm: vm)
                case 12: OnboardingInterestsView(vm: vm)
                case 13: OnboardingPhotoView(vm: vm)
                default: EmptyView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))
            .animation(.easeInOut(duration: 0.3), value: vm.step)
        }
        .background(IgniteTheme.background.ignoresSafeArea())
    }
}
