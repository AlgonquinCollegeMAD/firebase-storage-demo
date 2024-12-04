//
//  ContentView.swift
//  Firebase Storage Demo
//
//  Created by Vladimir Cezar on 2024.12.03.
//
import PhotosUI
import SwiftUI

struct ContentView: View {
  @State private var selectedImage: UIImage?
  @State private var uploadedImageURLs: [URL] = []
  @State private var isUploading = false
  
  let userID = "example_user"
  
  var body: some View {
    VStack {
      AppPickerView(selected: $selectedImage)
      
      if let image = selectedImage {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(height: 200)
        
        Button("Upload Photo") {
          Task {
            await uploadPhoto(image)
          }
        }
        .disabled(isUploading)
      }
      
      List(uploadedImageURLs, id: \.self) { url in
        AsyncImage(url: url) { phase in
          if let image = phase.image {
            image.resizable().scaledToFit()
          } else if phase.error != nil {
            Text("Failed to load image")
          } else {
            ProgressView()
          }
        }
        .frame(height: 100)
      }
    }
    .task {
      await fetchUploadedImages()
    }
    .padding()
  }
  
  private func uploadPhoto(_ image: UIImage) async {
    isUploading = true
    do {
      let url = try await StorageManager.shared.uploadImage(image, forUserID: userID)
      uploadedImageURLs.append(url)
    } catch {
      print("Upload failed: \(error.localizedDescription)")
    }
    isUploading = false
  }
  
  private func fetchUploadedImages() async {
    do {
      uploadedImageURLs = try await StorageManager.shared.fetchImageURLs(forUserID: userID)
    } catch {
      print("Failed to fetch images: \(error.localizedDescription)")
    }
  }
}
