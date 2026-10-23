# frozen_string_literal: true

require 'rails'
require 'zip'
require 'tmpdir'
require 'fileutils'
require 'securerandom'
require_relative '../../lib/solidus_gdpr/data_exporter/assemble_archive'

# Exercise the actual exporter without generating a dummy app or using a DB.
RSpec.describe SolidusGdpr::DataExporter::AssembleArchive do
  it 'preserves multiple exported JSON payloads under Rubyzip 3' do
    Dir.mktmpdir('gdpr-archive-contract') do |root|
      allow(Rails).to receive(:root).and_return(Pathname(root))
      files = { 'profile.json' => '{"name":"Example"}', 'orders.json' => '[{"id":1}]' }
      archive = described_class.new(files: files).call
      expect(File.dirname(archive)).to eq(File.join(root, 'tmp', 'exports'))
      contents = Zip::File.open(archive) { |zip| zip.to_h { |entry| [entry.name, entry.get_input_stream.read] } }
      expect(contents).to eq(files)
    end
  end
end
