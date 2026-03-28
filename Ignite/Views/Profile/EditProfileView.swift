import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var bio = ""
    @State private var city = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Name", text: $name)
                TextField("City", text: $city)
            }

            Section("About Me") {
                TextEditor(text: $bio)
                    .frame(height: 100)
            }

            Section {
                Button("Save Changes") {
                    // TODO: save to backend
                    dismiss()
                }
                .foregroundColor(.orange)
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            name = authViewModel.currentUser?.name ?? ""
            bio = authViewModel.currentUser?.bio ?? ""
            city = authViewModel.currentUser?.city ?? ""
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
