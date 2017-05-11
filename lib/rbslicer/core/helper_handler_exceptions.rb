# coding => utf-8

require 'rbslicer/exceptions'

module HelperHandlerExceptions
  SLICER_EXCEPTIONS = {
    2 => Exceptions::DemoUnavailableException,
    1502 => Exceptions::RequestRateLimitException,
    1507 => Exceptions::RequestBodySizeExceededException,
    2012 => Exceptions::IndexEntitiesLimitException,
    2013 => Exceptions::IndexColumnsLimitException
}
end
