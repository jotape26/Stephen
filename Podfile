# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

def shared_pods

 pod "Kingfisher"
  
end

target 'Stephen' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Stephen

  shared_pods

  pod "RxCocoa"
  pod "Moya/RxSwift"
  pod "SwiftMessages"


  target 'StephenTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'StephenUITests' do
    # Pods for testing
  end

end

target 'RandomDrinkExtension' do
  use_frameworks!

  shared_pods
  pod 'Moya'

end 
