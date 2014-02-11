describe StompParser::Frame do
  describe "#content_length" do
    it "returns content length if available" do
      message = StompParser::Frame.new("CONNECT", { "content-length" => "1337" }, nil)
      message.content_length.should eq 1337
    end

    it "returns nil if no content length defined" do
      message = StompParser::Frame.new("CONNECT", nil)
      message.content_length.should be_nil
    end

    it "raises an error if invalid content length defined" do
      message = StompParser::Frame.new("CONNECT", { "content-length" => "LAWL" }, nil)
      expect { message.content_length }.to raise_error(StompParser::Error, /invalid content length "LAWL"/)
    end
  end

  describe "#to_str" do
    specify "message with command only" do
      message = StompParser::Frame.new("CONNECT", nil)
      message.to_str.should eq "CONNECT\ncontent-length:0\n\n\x00"
    end

    specify "message with with headers" do
      message = StompParser::Frame.new("CONNECT", { "moo" => "cow", "boo" => "hoo" }, nil)
      message.to_str.should eq "CONNECT\nmoo:cow\nboo:hoo\ncontent-length:0\n\n\x00"
    end

    specify "message with with body" do
      message = StompParser::Frame.new("CONNECT", "this is a body")
      message.to_str.should eq "CONNECT\ncontent-length:14\n\nthis is a body\x00"
    end

    specify "message with escapeable characters in headers" do
      message = StompParser::Frame.new("CONNECT", { "k\\\n\r:" => "v\\\n\r:" }, nil)
      message.to_str.should eq "CONNECT\nk\\\\\\n\\r\\c:v\\\\\\n\\r\\c\ncontent-length:0\n\n\x00"
    end

    specify "message with binary body" do
      message = StompParser::Frame.new("CONNECT", "\x00ab\x00")
      message.to_str.should eq "CONNECT\ncontent-length:4\n\n\x00ab\x00\x00"
    end

    specify "overrides user-specified content-length" do
      message = StompParser::Frame.new("CONNECT", { "content-length" => "10" }, "\x00ab\x00")
      message.to_str.should eq "CONNECT\ncontent-length:4\n\n\x00ab\x00\x00"
    end
  end
end
