//
//  NodeOptions.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-04-09.
//


// NodeOptions.swift
import SwiftUI

struct NodeOptions {
    static let options: [String: String] = [
        "Dance": """

        def dance():
            background_music('angry.mp3')
            music_set_volume(50)
            for _ in range(2):
                crawler.do_action('stand', 1, speed)
                crawler.do_action('sit', 1, speed)
                crawler.do_action('push_up', 1, speed)
                crawler.do_action('backward', 1, speed)
                crawler.do_action('twist', 1, speed)

        """,
        "Approach": """

        def approach():
            for _ in range(2):
                crawler.do_action('forward', 2, speed)
                delay(200)

            crawler.do_action('stand', 1, speed)
            delay(2000)

        """,
        "Wave": """

        import math
        def wave():
            center_x, center_y, center_z = 45, 0, -50
            radius = 30
            num_points = 10
            angle_step = 2 * math.pi / num_points
            coords = [[[45, 45, -50], [45, 0, -50], [45, 0, -50], [45, 45, -50]]]
            for i in range(num_points):
                angle = i * angle_step
                x = center_x + radius * math.cos(angle)
                y = center_y + radius * math.sin(angle)
                z = center_z
                coords.append([[45, 45, -70], [x, y, z], [45, 0, -60], [45, 45, -30]])
            coords += [
                [[45, 45, -50], [45, 0, -30], [45, 0, -50], [45, 45, -50]],
                [[45, 45, -50], [45, 0, -40], [45, 0, -50], [45, 45, -50]],
                [[45, 45, -50], [45, 0, -50], [45, 0, -50], [45, 45, -50]],
            ]
            for coord in coords:
                crawler.do_step(coord, speed)

        """
    ]
}
