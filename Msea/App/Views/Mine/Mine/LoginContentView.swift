//
//  LoginContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/8.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import AlertToast

/// 登录界面
struct LoginContentView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = LoginViewModel()

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Menu {
                    ForEach(LoginField.allCases) { item in
                        Button {
                            viewModel.username = ""
                            viewModel.loginField = item
                        } label: {
                            Label(item.title, systemImage: item.icon)
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.loginField.title)

                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 8, height: 8)
                            .padding(.leading, -5)
                    }
                }

                Spacer()
            }
            .frame(width: 300)
            .padding(.bottom, -5)

            TextField(viewModel.loginField.placeholder, text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .frame(width: 300, height: 40)

            SecureField("输入密码", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300, height: 40)

            HStack {
                Text("安全提问:")

                Menu {
                    ForEach(LoginQuestion.allCases) { item in
                        Button {
                            if item == .no {
                                viewModel.answer = ""
                            }
                            viewModel.loginQuestion = item
                        } label: {
                            Label(item.title, systemImage: item.icon)
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.loginQuestion.title)

                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 8, height: 8)
                            .padding(.leading, -5)
                    }
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.theme, lineWidth: 1)
                    )
                }

                Spacer()
            }
            .frame(width: 300)

            if viewModel.loginQuestion != .no {
                TextField("输入答案", text: $viewModel.answer)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300, height: 40)
            }

            Button(viewModel.isLoading ? " " : "登录", action: {
                Task {
                    if await viewModel.login() {
                        dismiss()
                    }
                }
            })
            .showProgress(isShowing: $viewModel.isLoading, color: .white)
            .disabled(viewModel.isLoading)
                .buttonStyle(BigButtonStyle())
                .padding(.top, 20)
        }
        .toast(isPresenting: $viewModel.isToast, alert: {
            AlertToast(displayMode: .alert, type: .regular, title: viewModel.toastMessage)
        })
        .task {
            await viewModel.loadData()
        }
    }
}

struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginContentView()
    }
}
