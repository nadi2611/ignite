import SwiftUI

struct VerifiedBadge: View {
    var size: CGFloat = 14
    
    var body: some View {
        Image(systemName: "checkmark.seal.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(.blue)
    }
}
