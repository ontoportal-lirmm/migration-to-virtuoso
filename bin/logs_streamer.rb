require 'file/tail'
require 'logger'

logger = Logger.new('app_logs.log')

File::Tail::Logfile.open('./virtuoso/') do |log|
  log.tail do |line|
    logger.info(line) if line.match(/(Error|Warning|Info)/)
  end
end
