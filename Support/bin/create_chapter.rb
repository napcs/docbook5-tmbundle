#!/usr/bin/env ruby
bundle_lib = ENV['TM_BUNDLE_SUPPORT'] + '/lib'
$LOAD_PATH.unshift(bundle_lib) if ENV['TM_BUNDLE_SUPPORT'] and !$LOAD_PATH.include?(bundle_lib)

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

require 'text_mate'

require 'fileutils'
# If text is selected, create a partial out of it
if TextMate.selected_text
  chapter_name = TextMate::UI.request_string(
    :title => "Create a partial from the selected text", 
    :default => "",
    :prompt => "Name of the new chapter: (omit the .xml)",
    :button1 => 'Next'
  )

  title = TextMate::UI.request_string(
    :title => "Give this chapter a title", 
    :default => "",
    :prompt => "Title of the new chapter.",
    :button1 => 'Create'
  )


  if chapter_name
    
    path = File.dirname(TextMate.filepath)
    chapter_path = File.join(path, "chapter_#{chapter_name}")
    chapter = File.join(chapter_path, "#{chapter_name}.xml")
    insert_chapter_path = "chapter_#{chapter_name}/#{chapter_name}.xml"
    # Create the partial file
    if File.exist?(chapter)
      unless TextMate::UI.request_confirmation(
        :button1 => "Overwrite",
        :button2 => "Cancel",
        :title => "The chapter file already exists.",
        :prompt => "Do you want to overwrite it?"
      )
        TextMate.exit_discard
      end
    else
      FileUtils.mkdir_p chapter_path
    end

    chapter_text = %Q{<?xml version="1.0" encoding="UTF-8"?>
      <chapter version="5.0" xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:svg="http://www.w3.org/2000/svg"
        xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:html="http://www.w3.org/1999/xhtml"
        xmlns:db="http://docbook.org/ns/docbook">
        <title>#{title}</title>

        #{TextMate.selected_text}

      </chapter>

    }



    file = File.open(chapter, "w") do |f|
              f << (chapter_text) 
    end
     
    TextMate.rescan_project

    # Return the new render :partial line
    print "<xi:include xmlns:xi=\"http://www.w3.org/2001/XInclude\" href=\"#{insert_chapter_path}\" />\n"
  else
    TextMate.exit_discard
  end
else
  TextMate.exit_show_tool_tip("You must select some text.")

end




