$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'stringio'
require 'test/unit'
require 'pdf/reader'

class PDF::Reader::XRef
  attr_accessor :xref
end

context "The PDF::Reader::Content class" do

  specify "should send the correct callbacks when processing instructions containing a single text block" do

    # mock up an object that will be called with callbacks. This will test that
    # the content class correctly recognises all instructions
    receiver = mock("receiver")
    receiver.should_receive(:begin_text_object).once             # BT
    receiver.should_receive(:move_text_position).once            # Td 
    receiver.should_receive(:set_text_font_and_size).once        # Tf
    receiver.should_receive(:set_text_rendering_mode).once       # Tr
    receiver.should_receive(:show_text).once                     # Tj
    receiver.should_receive(:end_text_object).once               # ET

    # The instructions to test with
    instructions = "BT\n 36.000 794.330 Td\n /F1 10.0 Tf\n 0 Tr\n (047174719X) Tj\n ET"

    # process the instructions
    content = PDF::Reader::Content.new(receiver, nil)
    content.content_stream(instructions) 
  end

  specify "should send the correct callbacks when processing instructions containing 2 text blocks" do

    # mock up an object that will be called with callbacks. This will test that
    # the content class correctly recognises all instructions
    receiver = mock("receiver")
    receiver.should_receive(:begin_text_object).twice            # BT
    receiver.should_receive(:move_text_position).twice           # Td 
    receiver.should_receive(:set_text_font_and_size).twice       # Tf
    receiver.should_receive(:set_text_rendering_mode).twice      # Tr
    receiver.should_receive(:show_text).twice                    # Tj
    receiver.should_receive(:end_text_object).twice              # ET

    # The instructions to test with
    instructions = "BT 36.000 794.330 Td /F1 10.0 Tf 0 Tr (047174719X) Tj ET\n BT 36.000 782.770 Td /F1 10.0 Tf 0 Tr (9780300110562) Tj ET"

    # process the instructions
    content = PDF::Reader::Content.new(receiver, nil)
    content.content_stream(instructions) 
  end

  specify "should send the correct callbacks when processing instructions containing an inline image" do

    # mock up an object that will be called with callbacks. This will test that
    # the content class correctly recognises all instructions
    receiver = mock("receiver")
    receiver.should_receive(:begin_inline_image).once   # BI
    receiver.should_receive(:begin_inline_image_data).once    # ID
    receiver.should_receive(:end_inline_image).once     # EI

    # access a content stream with an inline image
    filename = File.dirname(__FILE__) + "/data/inline_image.pdf"
    buffer =   PDF::Reader::Buffer.new(File.new(filename, "r"))
    xref =     PDF::Reader::XRef.new(buffer)
    xref.xref[3] = Hash.new
    xref.xref[3][0] = 248
    ref =      PDF::Reader::Reference.new(3,0)
    obj, stream = xref.object(ref)

    # process the instructions
    content = PDF::Reader::Content.new(receiver, nil)
    content.content_stream(stream) 
  end
end