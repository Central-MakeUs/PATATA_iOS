//
//  ProfileEditView.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import SwiftUI
import ComposableArchitecture

struct ProfileEditView: View {
    @Perception.Bindable var store: StoreOf<ProfileEditFeature>
    
    @State private var selectedImage: [UIImage] = []
    @State private var isPermission: Bool = false
    @State private var isSize: Bool = false
    @State private var isResizing: Bool = false
    @State private var exceed: Bool = false
    @State private var totalExceed: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            if store.dataState == .progress {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationBarBackButtonHidden(true)
            } else {
                contentView
                    .onAppear {
                        store.send(.viewCycle(.onAppear))
                    }
                    .background(.gray20)
                    .navigationBarBackButtonHidden()
                    .onTapGesture {
                        hideKeyboard()
                    }
            }
        }
    }
}

extension ProfileEditView {
    private var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            fakeNavgationBar
                .padding(.bottom, 12)
                .background(.white)
            
            myProfileImage
                .padding(.top, 40)
            
            nickNameView
                .padding(.top, 40)
                .padding(.horizontal, 15)
            
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Text("완료")
                        .foregroundStyle(.white)
                        .textStyle(.subtitleM)
                        .padding(.vertical, 12)
                    
                    Spacer()
                }
                .background(store.textValueChange ? .black : .gray50)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 15)
                .padding(.bottom, 20)
                .padding(.top, 10)
                .asButton {
                    store.send(.viewEvent(.tappedConfirmButton))
                }
                
            }
            .background(.white)
        }
    }
    
    private var fakeNavgationBar: some View {
        ZStack {
            HStack {
                NavBackButton {
                    store.send(.viewEvent(.tappedBackButton))
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            Text(store.viewState == .first ? "프로필 설정" : "프로필 수정")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
        }
    }
    
    private var myProfileImage: some View {
        PhotoPickerView(selectedImages: $selectedImage, showPermissionAlert: $isPermission, isImageSizeValid: $isSize, resizedImageDatas: $store.imageData.sending(\.bindingImageData), isResizing: $isResizing, invalidExceed: $exceed, totalExceed: $totalExceed, maxSelectedCount: 1) {
            Group {
                
                if selectedImage.isEmpty {
                    if let imageData = store.profileData.profileImage {
                        DownImageView(url: imageData, option: .mid, fallBackImg: store.profileImage)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(alignment: .bottomTrailing) {
                                Image("EditActive")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .background(
                                        Circle()
                                            .foregroundStyle(.white)
                                            .shadow(color: .shadowColor, radius: 8)
                                    )
                            }
                    } else {
                        Image(store.profileImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(alignment: .bottomTrailing) {
                                Image("EditActive")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .background(
                                        Circle()
                                            .foregroundStyle(.white)
                                            .shadow(color: .shadowColor, radius: 8)
                                    )
                            }
                    }
                } else {
                    Image(uiImage: selectedImage[0])
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(alignment: .bottomTrailing) {
                            Image("EditActive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle()
                                        .foregroundStyle(.white)
                                        .shadow(color: .shadowColor, radius: 8)
                                )
                                .asButton {
                                    isPermission = true
                                }
                        }
                }
                
            }
        }
    }
    
    private var nickNameView: some View {
        VStack {
            HStack {
                Text("닉네임")
                    .textStyle(.subtitleM)
                    .foregroundStyle(.textDefault)
                
                Spacer()
            }
            
            TextField("", text: $store.nickname.sending(\.bindingNickname))
                .textStyle(.subtitleS)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .padding(.horizontal, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    ZStack(alignment: .leading) {
                        if store.nickname.isEmpty {
                            HStack {
                                Text("최소 2글자, 최대 10로 입력해주세요")
                                    .textStyle(.bodyS)
                                    .foregroundColor(.textDisabled)
                                    .padding(.leading, 16)
                                
                                Spacer()
                                
                            }
                        }
                        
                        HStack {
                            Spacer()
                            
                            Image("CircleXActive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 16)
                                .opacity(store.cancleButtonHide ? 0 : 1)
                                .asButton {
                                    store.send(.viewEvent(.tappedClearNickName))
                                }
                        }
                    }
                    
                    if !store.isValid {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.red100, lineWidth: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .onChange(of: store.nickname) { newValue in
                    store.send(.validCheckText(newValue))
                }
            
            HStack {
                Text("이미 사용 중인 닉네임입니다.")
                    .foregroundStyle(.red100)
                    .textStyle(.captionM)
                    .opacity(store.isValid ? 0 : 1)
                
                Spacer()
            }
        }
    }
}
