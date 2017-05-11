# coding: utf-8

module Exceptions
  class SlicingDiceException < StandardError; 
    def initialize(data)
      @code = data.fetch('code', nil)
      @message = data.fetch('message', nil)
      @more_info = data.fetch('more-info', nil)

      super(@message)
    end
    def code
      @code
    end
    def more_info
      @more_info
    end
  end
  
  class SlicingDiceHTTPError < SlicingDiceException; end

  class DemoUnavailableException < SlicingDiceException; end

  class RequestRateLimitException < SlicingDiceException; end

  class RequestBodySizeExceededException < SlicingDiceException; end

  class IndexEntitiesLimitException < SlicingDiceException; end

  class IndexColumnsLimitException < SlicingDiceException; end

end
