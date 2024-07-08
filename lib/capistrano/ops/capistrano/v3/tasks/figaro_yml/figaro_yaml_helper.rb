# frozen_string_literal: true

module FigaroYmlHelper
  def environments
    Dir.glob('config/deploy/*.rb')
  end

  def local_yaml
    YAML.safe_load(File.read('config/application.yml')) || {}
  end

  def write_to_file(file, content)
    File.open(file, 'w') do |f|
      f.write(content)
    end
  end

  def write_combined_yaml(yamls_combined)
    if yamls_combined.empty?
      info 'No data to write.'
    else
      # write to new file
      info 'writing to config/application.yml'
      write_to_file('config/application.yml', yamls_combined.to_yaml)
    end
  end

  def compare_hashes(hash1, hash2)
    all_keys = hash1.keys | hash2.keys # Union of all keys from both hashes
    all_keys.each_with_object({}) do |key, changes_hash|
      old_value = hash2[key].nil? ? 'nil' : hash2[key].to_s
      new_value = hash1[key].nil? ? 'nil' : hash1[key].to_s

      changes_hash[key] = { old: old_value, new: new_value } if old_value != new_value
    end.tap { |changes| return changes.empty? ? nil : changes }
  end

  def print_changes(changes, message)
    return unless changes

    puts "#{message}:\n\n"
    changes.each do |key, diff|
      puts "#{key}: #{diff[:old]} => #{diff[:new]}"
    end
    puts "\n"
  end

  def ask_to_overwrite(question)
    answer = ''
    until %w[y n].include?(answer)
      print "#{question}? (y/N): "
      answer = $stdin.gets.strip.downcase
    end
    answer == 'y'
  end

  def configs(yaml, env)
    stage_yml = yaml[env.to_s]&.sort.to_h
    global_yml = remove_nested(yaml)&.sort.to_h
    [global_yml, stage_yml]
  end

  def remove_nested(hash)
    hash.each_with_object({}) do |(key, value), new_hash|
      new_hash[key] = value unless value.is_a?(Hash)
    end
  end

  def sort_with_nested(hash)
    hash.each_with_object({}) do |(key, value), new_hash|
      new_hash[key] = value.is_a?(Hash) ? sort_with_nested(value) : value
    end.sort.to_h
  end
end
