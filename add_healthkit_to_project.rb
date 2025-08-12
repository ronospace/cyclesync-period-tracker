#!/usr/bin/env ruby

require 'xcodeproj'

# Open the Xcode project
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Runner target
runner_target = project.targets.find { |target| target.name == 'Runner' }

# Find the Runner group
runner_group = project.main_group.find_subpath('Runner')

# Add HealthKitPlugin.swift to the project
healthkit_plugin_path = 'HealthKitPlugin.swift'
file_reference = runner_group.new_reference(healthkit_plugin_path)

# Add to the Runner target's source build phase
runner_target.source_build_phase.add_file_reference(file_reference)

# Save the project
project.save

puts "✅ HealthKitPlugin.swift added to Xcode project successfully!"
