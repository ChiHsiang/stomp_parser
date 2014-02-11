package stomp_parser.stomp;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyFixnum;
import org.jruby.RubyString;
import org.jruby.RubyNumeric;
import org.jruby.RubyException;
import org.jruby.exceptions.RaiseException;

import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.Block;

import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;

%%{
  machine message;
  alphtype byte;

  action mark {
    mark = p;
  }

  action mark_message {
    mark_message = context.runtime.getClassFromPath("StompParser::Stomp::Message").callMethod("new", context.nil, context.nil);
    mark_message_size = 0;
  }

  action write_command {
    mark_message.callMethod(context, "write_command", RubyString.newString(context.runtime, data, mark, p - mark));
    mark = -1;
  }

  action mark_key {
    mark_key = RubyString.newString(context.runtime, data, mark, p - mark);
    mark = -1;
  }

  action write_header {
    IRubyObject args[] = { mark_key, RubyString.newString(context.runtime, data, mark, p - mark) };
    mark_message.callMethod(context, "write_header", args);
    mark_key = null;
    mark = -1;
  }

  action finish_headers {
    IRubyObject content_length = mark_message.callMethod(context, "content_length");

    if ( ! content_length.isNil()) {
      mark_content_length = RubyNumeric.num2int(content_length);
    } else {
      mark_content_length = -1;
    }
  }

  action write_body {
    mark_message.callMethod(context, "write_body", RubyString.newString(context.runtime, data, mark, p - mark));
    mark = -1;
  }

  action consume_null {
    ((mark_content_length != -1) && ((p - mark) < mark_content_length))
  }

  action consume_octet {
    ((mark_content_length == -1) || ((p - mark) < mark_content_length))
  }

  action check_message_size {
    mark_message_size += 1;
    if (mark_message_size > maxMessageSize) {
      RubyModule messageSizeExceeded = context.runtime.getClassFromPath("StompParser::Stomp::MessageSizeExceeded");
      RubyException error = (RubyException) messageSizeExceeded.callMethod("new");
      throw new RaiseException(error);
    }
  }

  action finish_message {
    block.yield(context, mark_message);
    mark_message = null;
  }

  include message_common "parser_common.rl";
}%%

@JRubyClass(name="JavaParser", parent="Object")
public class JavaParser extends RubyObject {
  %% write data noprefix;

  private class State {
    public int cs = JavaParser.start;
    public byte[] chunk;
    public int mark = -1;
    public RubyString mark_key;
    public IRubyObject mark_message;
    public int mark_message_size = -1;
    public int mark_content_length = -1;
  }

  private RubyException parseError;
  private long maxMessageSize;
  private State state;

  public JavaParser(Ruby runtime, RubyClass klass) {
    super(runtime, klass);
    state = new State();
    parseError = null;
  }

  @JRubyMethod
  public IRubyObject initialize(ThreadContext context) {
    RubyModule mStomp = context.runtime.getClassFromPath("StompParser::Stomp");
    return initialize(context, mStomp.callMethod("max_message_size"));
  }

  @JRubyMethod(argTypes = {RubyFixnum.class})
  public IRubyObject initialize(ThreadContext context, IRubyObject maxMessageSize) {
    this.maxMessageSize = ((RubyFixnum) maxMessageSize).getLongValue();
    return context.nil;
  }

  @JRubyMethod(argTypes = {RubyString.class})
  public IRubyObject parse(ThreadContext context, IRubyObject chunk, Block block) {
    if (parseError == null) {
      int p;
      byte data[] = null;
      byte bytes[] = ((RubyString) chunk).getBytes();

      if (state.chunk != null) {
        p = state.chunk.length;
        data = new byte[state.chunk.length + bytes.length];
        System.arraycopy(state.chunk, 0, data, 0, state.chunk.length);
        System.arraycopy(bytes, 0, data, state.chunk.length, bytes.length);
      } else {
        p = 0;
        data = bytes;
      }

      int pe = data.length;

      int cs = state.cs;
      int mark = state.mark;
      RubyString mark_key = state.mark_key;
      IRubyObject mark_message = state.mark_message;
      int mark_message_size = state.mark_message_size;
      int mark_content_length = state.mark_content_length;

      %% write exec;

      if (mark != -1) {
        state.chunk = data;
      } else {
        state.chunk = null;
      }

      state.cs = cs;
      state.mark = mark;
      state.mark_key = mark_key;
      state.mark_message = mark_message;
      state.mark_message_size = mark_message_size;
      state.mark_content_length = mark_content_length;

      if (cs == error) {
        IRubyObject args[] = { RubyString.newString(context.runtime, data), RubyFixnum.newFixnum(context.runtime, (long) p) };
        parseError = (RubyException) context.runtime.getClassFromPath("StompParser::Stomp").callMethod(context, "build_parse_error", args);
      }
    }

    if (parseError != null) {
      throw new RaiseException(parseError);
    }

    return context.nil;
  }
}
