#!/usr/bin/env ruby

require 'xcodeproj'

# Open the Xcode project
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Runner target
runner_target = project.targets.find { |target| target.name == 'Runner' }

# Find the Runner group
runner_group = project.main_group.find_subpath('Runner')

# Remove all existing HealthKitPlugin references
project.objects.each do |uuid, object|
  if object.respond_to?(:path) && object.path && object.path.include?('HealthKitPlugin.swift')
    puts "Removing existing HealthKitPlugin reference: #{object.path}"
    object.remove_from_project
  end
  if object.respond_to?(:display_name) && object.display_name && object.display_name.include?('HealthKitPlugin.swift')
    puts "Removing existing HealthKitPlugin build file: #{object.display_name}"
    object.remove_from_project
  end
end

# Clean up any HealthKitPlugin entries from source build phase
runner_target.source_build_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path && build_file.file_ref.path.include?('HealthKitPlugin.swift')
    puts "Removing HealthKitPlugin from source build phase"
    build_file.remove_from_project
  end
end

# Add HealthKitPlugin.swift to the project with correct relative path
healthkit_plugin_path = 'HealthKitPlugin.swift'
file_reference = runner_group.new_reference(healthkit_plugin_path)

# Add to the Runner target's source build phase
runner_target.source_build_phase.add_file_reference(file_reference)

# Save the project
project.save

puts "✅ HealthKitPlugin.swift cleaned up and added to Xcode project successfully!"
