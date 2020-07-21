require 'rails_helper'
require 'lesson_content_publisher'

RSpec.describe LessonContentPublisher do

  let(:aws_object) { instance_double(Aws::S3::Object) }
  let(:lesson_content) { create(:lesson_content) }

  before(:each) do
    allow_any_instance_of(LessonContentPublisher::AwsS3Bucket).to receive(:object).and_return(aws_object)
  end

  describe '#publish' do
    context 'when valid Rise360 zipfile' do

      it 'unzips to S3' do
        allow(aws_object).to receive(:public_url).and_return("https://S3-bucket-path/lessons/somekey/index.html")
        expect(aws_object).to receive(:put).with(Hash).at_least(10).times # There are a bunch of files in there to unzip. 10 is arbitrary
        lesson_content # The creation of this object causes it to be published. 
      end

    end
  end

  describe '#launch_url' do
    context 'when valid Rise360 zipfile' do

      it 'returns launch URL' do
        allow(LessonContentPublisher).to receive(:publish).and_return("https://S3-bucket-path/lessons/somekey/index.html")
        expect(aws_object).to receive(:public_url)
        LessonContentPublisher.launch_url(lesson_content.lesson_content_zipfile.key)
      end

    end
  end

end
