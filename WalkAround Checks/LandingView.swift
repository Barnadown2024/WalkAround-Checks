import SwiftUI

struct LandingView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color or image
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Center the content
                    VStack(spacing: 20) {
                        // Add your logo or image
                        Image(systemName: "box.truck.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.primary)
                        
                        // Add your title or welcome text
                        Text("Welcome to WalkAround Checks")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        // Add a brief description or tagline
                        Text("Your daily vehicle inspection companion")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Navigation button to start the checklist
                        NavigationLink(destination: ChecklistView()) {
                            Text("Start Inspection")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Navigation button to view history
                        NavigationLink(destination: SummaryView()) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath") // Use an appropriate symbol
                                    .font(.headline)
                                Text("View History")
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
} 