require 'json'
require 'net/http'
require 'uri'
require 'time'

def lambda_handler(event:, context:)
  detail = event['detail']
  pipeline = detail['pipeline']
  stage = detail['stage']
  state = detail['state']
  region = event['region']

  kst_time = Time.now.getlocal('+09:00').strftime("%Y-%m-%d %H:%M:%S KST")

  color = case state
          when 'Succeeded' then 0x2ECC71  # 초록
          when 'Failed'    then 0xE74C3C  # 빨강
          when 'InProgress'then 0x3498DB  # 파랑
          else 0x95A5A6                   # 회색
          end

  embed = {
    title: "CodePipeline Stage 업데이트",
    description: "**Pipeline:** `#{pipeline}`\n" \
                 "**Stage:** `#{stage}`\n" \
                 "**State:** `#{state}`",
    color: color,
    footer: {
      text: "AWS Region: #{region} | #{kst_time}"
    }
  }

  webhook_url = ENV['DISCORD_WEBHOOK_URL']
  uri = URI.parse(webhook_url)

  header = { 'Content-Type': 'application/json' }
  payload = {
    content:"<@&1315864971426529281>,
    username: "AWS CodePipeline Notifier",
    avatar_url: "https://a0.awsstatic.com/libra-css/images/logos/aws_logo_smile_1200x630.png",
    embeds: [embed]
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = payload.to_json

  response = http.request(request)
  puts "Discord 응답 코드: #{response.code}"

  { statusCode: 200, body: 'Success' }
end

