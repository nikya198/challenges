class Challenge
    def challenges
        require 'net/http'
        require 'uri'
        require 'date'
        uri = URI.parse('http://challenge.z2o.cloud/challenges')

        while true
            puts "ニックネームを入力してください"
            nickname=gets

            #postリクエスト、レスポンス
            postRespanse = Net::HTTP.post_form(uri, { 'nickname' => nickname })
            # data = JSON.parse(postRespanse.body.to_s)
            # puts data
            #チャレンジID
            id = postRespanse.body[7..70]
            #現在日時
            nowTime = Time.now.strftime('%s%L').to_i.to_s
            #呼出予定時刻
            yoteiTime = postRespanse.body[86..98]
    
            #呼出予定時刻になるまで待機
            self.class.timer_method(yoteiTime,nowTime)

            #putリクエスト、レスポンス
            putResponse = self.class.put_reqest(id,uri)
            #差異時刻
            totalDiff = putResponse.body[139..141]
            #呼出予定時刻
            yoteiTime = putResponse.body[86..98]

            while true
                #呼出予定時刻になるまで待機
                self.class.timer_method(yoteiTime,nowTime)

                #putリクエスト、レスポンス
                putResponse = self.class.put_reqest(id,uri)
                #差異時刻
                yoteiTime = putResponse.body[86..98]
                #呼出予定時刻
                totalDiff = putResponse.body[139..141]

                #差異時刻がnilになったら終了し結果を表示する
                if totalDiff == nil
                    puts putResponse.body
                    return true
                end
            end
        end
    end
    
    #呼出予定時刻になるまで待機
    def self.timer_method(yoteiTime,nowTime)
        until yoteiTime == nowTime
            nowTime = Time.now.strftime('%s%L').to_i.to_s
        end
    end
    
    #putリクエスト、レスポンス
    def self.put_reqest(id,uri)
        putReqest = Net::HTTP::Put.new(uri, initheader = { 'X-Challenge-Id' => id})
        putResponse = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(putReqest) }
        return putResponse
    end  
end

a = Challenge.new
a.challenges

