//
//  NodeView.swift
//  RoboSketch
//
//  Created by Jarin Thundathil on 2025-04-02.

import SwiftUI

struct NodeView: View {
    @Binding var node: Node
    var color: Color

    @State private var isActive = false
    @State private var showDropdown = false
    

    var body: some View {
        ZStack {
            // Fullscreen invisible background to dismiss dropdown on tap
            if showDropdown {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            showDropdown = false
                            isActive = false
                        }
                    }
            }

            // Node + anchored dropdown menu
            ZStack(alignment: .top) {
                // Dropdown menu positioned below node
                if showDropdown {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 32) // push menu below node
                        VStack(spacing: 0) {
                            // Iterate over sorted keys from the dictionary for stable order.
                            ForEach(NodeOptions.options.keys.sorted(), id: \.self) { key in
                                Button(action: {
                                    withAnimation {
                                        showDropdown = false
                                        isActive = false
                                    }
                                    node.selectedOption = key
                                }) {
                                    Text(key)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(Color.white)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color.gray.opacity(0.15)),
                                    alignment: .bottom
                                )
                            }
                        }
                        .frame(width: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                .background(Color.white.cornerRadius(10))
                        )
                        .shadow(radius: 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                // Node remains in fixed position
                Circle()
                    .fill(color)
                    .frame(width: isActive ? 22 : 16, height: isActive ? 22 : 16)
                    .scaleEffect(showDropdown ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showDropdown)
                    .onTapGesture {
                        withAnimation {
                            isActive.toggle()
                            showDropdown.toggle()
                        }
                    }
                    .padding(10)
                    .contentShape(Rectangle())
            }
        }
        .position(node.position)
        .zIndex(showDropdown ? 1 : 0)
    }
}
