module Genotide
  module BroadcastTimeDimension

    class Day < Genotide::Piece

      def initialize
        super(:accepts => nil)
      end

      def is_full?(piece)
        pieces.count == 1
      end

    end

    class Week < Genotide::Piece

      def initialize
        super(:accepts => Day)
      end

      def is_full?(piece)
        pieces.count == 7
      end

    end

    class Month < Genotide::Piece

      def initialize
        super(:accepts => Week)
      end

      def is_full?(piece)
        return false if pieces.empty?
        bow = piece.beginning_of_week
        eow = piece.end_of_week
        bom = piece.beginning_of_month
        pieces.last.is_full?(piece) && (bow.month != eow.month || bom == bow)
      end
    end

    class Quarter < Genotide::Piece

      def initialize
        super(:accepts => Month)
      end

      def is_full?(piece)
        return false if pieces.empty?
        pieces.count == 3 && pieces.last.is_full?(piece)
      end

    end

    class Year < Genotide::Piece

      def initialize
        super(:accepts => Quarter)
      end

      def is_full?(piece)
        return false if pieces.empty?
        pieces.count == 4 && pieces.last.is_full?(piece)
      end

    end

    class BroadcastTimeDimension < Genotide::Piece

      def initialize(options = {})
        super(:accepts => Year)
        @first_day_of_week = options[:first_day_of_week] || "Sun"
        @from = options[:from]
        @to = options[:to]
        fail "First day of week has to be one of #{Date::ABBR_DAYNAMES}" if Date::ABBR_DAYNAMES.index(@first_day_of_week).nil?
        fail "First date (#{@from}) is not the day that is set as beginning of week (#{@first_day_of_week})" if @from.strftime("%a") != @first_day_of_week
      end

      def is_full?(piece)
        false
      end

    end

    def self.generate(from, to, options)
      td = BroadcastTimeDimension.new(options.merge({
        :from => from,
        :to => to
      }))
      puts "Warning: the from date (#{from.inspect}) is not monday" unless from.beginning_of_week == from
      (from..to).each do |date|
        td.add(date)
      end
      td
    end

    def save_as_csv(what, header, filename, &block)
      measurement = Benchmark.measure do
        CSV.open(filename, "w") do |csv|
          csv << header
          what.each do |day|
            yield(day).each do |line|
              csv << line
            end
          end
        end
      end
      puts "Saving #{filename}. Processing took #{measurement.real.round(2)} seconds"
    end

    def save(options={})

      def aggregate_on(whats, on_whats)
        stuff = nil
        measurement = Benchmark.measure do
          stuff = whats.reduce([]) do |memo, what|
            what.get_all(on_whats).each do |on_what|
              memo << what.index(on_what)
            end
            memo
          end
        end
        puts "Aggregating #{on_whats.to_s} took #{measurement.real.round(2)} seconds"
        stuff.uniq
      end

      def generate_lookup(what, file_name, letter)
        save_as_csv(what, [:id, :descr_default], file_name) do |item|
          [[
            item,
            "#{letter}#{item}"
          ]]
        end
      end


      # OUTPUT 
      file_prefix = options[:file_prefix]
      fail if file_prefix.nil?
      
      
      
      years = get_all(Year)
      quarters = get_all(Quarter)
      months = get_all(Month)
      weeks = get_all(Week)
      
      header = [:year_id, :descr_default]
      
      save_as_csv(years, header, "#{file_prefix}_lu_year.csv") do |year|
        [[
          years.index(year),
          "FY#{year.get(Date, :last).year}"
        ]]
      end
      
      header = [:quarter_id, :year_id, :quarter_of_year, :descr_default]
      save_as_csv(years, header, "#{file_prefix}_lu_quarter.csv") do |year|
        year.get_all(Quarter).map do |quarter|
          [
            quarters.index(quarter),
            years.index(year),
            # quarter.get(Date, :last).year,
            year.index(quarter),
            "#{year.index(quarter)}/#{quarter.get(Date, :last).year}"
          ]
        end
      end
      
      header = [:month_id, :year_id, :month_of_year, :quarter_id, :quarter_of_year, :month_of_quarter, :descr_default, :desc_num, :desc_us_long]
      save_as_csv(years, header, "#{file_prefix}_lu_month.csv") do |year|
        year.get_all(Quarter).reduce([]) do |memo, quarter|
          res = quarter.get_all(Month).map do |month|
            [
              months.index(month),            # :month_id,
              years.index(year),
              # month.get(Date, :last).year,    # :year_id,
              year.index(month),              # :month_of_year,
              years.index(quarter),           # :quarter_id,
              year.index(quarter),            # :quarter_of_year,
              quarter.index(month),            # :month_of_quarter,
              "#{month.get(Date, :last).strftime('%b')} #{month.get(Date, :last).year}", # :descr_default,
              "#{month.get(Date, :last).strftime('%-m')}/#{month.get(Date, :last).year}",# :desc_num,
              "#{month.get(Date, :last).strftime('%B')} #{month.get(Date, :last).year}"# :desc_us_long
            ]
          end
          memo.concat(res)
        end
      end
      
      header = [:week_id, :descr_week_quarter, :descr_from_to, :descr_default, :descr_week_year, :descr_number, :descr_week_quarter_cont]
      save_as_csv(years, header, "#{file_prefix}_lu_week.csv") do |year|
        year.get_all(Quarter).reduce([]) do |memo, quarter|
          res = quarter.get_all(Week).map do |week|
            first = week.get(Date, :first)
            last  = week.get(Date, :last)
            current_year = year.get(Date, :last).year
            week_of_year = year.index(week)
            week_of_quarter = year.index(week)
            quarter_of_year = year.index(quarter)
            [
              years.index(week),                                                  # :week_id,
              "W#{week_of_quarter}/Q#{quarter_of_year}/#{current_year}",             # :descr_week_quarter,
              "#{first.strftime('%b %d,%Y')} - #{last.strftime('%b %d,%Y')}",     # :descr_from_to, "#{week[:current_date].strftime('%b %d,%Y')} - #{week[:current_date].advance(:days => 6).strftime('%b %d,%Y')}"
              "#{first.strftime('Wk. of %a %m/%d/%Y')}",                          # :descr_default, 
              "W#{week_of_year}/#{current_year}",                                 # :descr_week_year,
              "W#{week_of_year}/#{current_year}",                                 # :descr_number
              "W#{week_of_year}/Q#{quarter_of_year}/#{current_year}"              # :descr_week_quarter_cont
            ]
          end
          memo.concat(res)
        end
      end

      data = JSON.parse(File.read('gdc_lookup.json'))
      gdc_lookup = {}
      data.each_pair do |key, val|
        gdc_lookup[Date.strptime(key, '%Y-%m-%d')] = val
      end

      header = [:id, :id_day_in_year, :id_quarter_in_year, :id_month_in_quarter, :id_month_in_year, :id_week, :id_week_in_year, :id_day_in_week, :id_week_in_quarter, :id_day_in_quarter, :id_month, :id_day_in_month, :id_year, :id_quarter, :desc_eu, :descr_default, :desc_us, :desc_iso, :desc_us_long, :desc_us2]
      save_as_csv(years, header, "#{file_prefix}_lu_day.csv") do |year|
        year.get_all(Quarter).reduce([]) do |quarter_memo, quarter|
          quarter_res = quarter.get_all(Month).reduce([]) do |month_memo, month|
            month_res = month.get_all(Week).reduce([]) do |week_memo, week|
              week_res = week.get_all(Date).map do |date|
                [
                  gdc_lookup[date],                         #:id,
                  year.index(date),                         #:id_day_in_year,
                  year.index(quarter),                      #:id_quarter_in_year,
                  quarter.index(month),                     #:id_month_in_quarter,
                  year.index(month),                        #:id_month_in_year,
                  years.index(week),                        #:id_week,
                  year.index(week),                         #:id_week_in_year,
                  week.index(date),                         #:id_day_in_week,
                  quarter.index(week),                      #:id_week_in_quarter,
                  quarter.index(date),                      #:id_day_in_quarter,
                  years.index(month),                       #:id_month,
                  month.index(date),                        #:id_day_in_month,
                  years.index(year),                        #:id_year,
                  years.index(quarter),                     # :id_quarter,
                  date.strftime("%d/%m/%Y"),                # :desc_eu,
                  date.strftime("%Y-%m-%d"),                # :descr_default,
                  date.strftime("%m/%d/%Y"),                # :desc_us,
                  date.strftime("%d-%m-%Y"),                # :desc_iso,
                  date.strftime("%a, %b %d, %Y"),           # :desc_us_long,
                  date.strftime("%_d/%_m/%y").gsub(" ", "") # :desc_us2
                ]
              end
              week_memo.concat(week_res)
            end
            month_memo.concat(month_res)
          end
          quarter_memo.concat(quarter_res)
        end
      end

    # 
    #   #########
    # 
    #   # LOOKUPS
    # 
    #   #########
    # 

    # WEEKS OF QUARTER
    generate_lookup(aggregate_on(quarters, Week), "#{file_prefix}_lu_week_in_quarter.csv", 'W')

    # DAY IN YEAR
    generate_lookup(aggregate_on(years, Date), "#{file_prefix}_lu_day_in_year.csv", 'D')

    # MONTH IN QUARTER
    generate_lookup(aggregate_on(quarters, Month), "#{file_prefix}_lu_month_in_quarter.csv", 'D')

    # WEEK IN YEAR
    generate_lookup(aggregate_on(years, Week), "#{file_prefix}_lu_week_in_year.csv", 'W')

    # EUWEEK IN YEAR
    
    # DAYS IN MONTH
    generate_lookup(aggregate_on(months, Date), "#{file_prefix}_lu_day_in_month.csv", 'D')

    # QUARTERS IN YEAR
    generate_lookup(aggregate_on(years, Quarter), "#{file_prefix}_lu_quarter_in_year.csv", 'Q')
    
    # DAY OF QUARTER
    generate_lookup(aggregate_on(quarters, Date), "#{file_prefix}_lu_day_in_quarter.csv", 'D')

    # MONTH IN YEAR
    stuff = []
    years.each do |year|
      year.get_all(Quarter).each do |quarter|
        quarter.get_all(Month).each do |month|
          stuff << [year.index(quarter), year.index(month)]
        end
      end
    end

    save_as_csv(stuff.uniq, [:id, :descr_default, :desc_mq, :desc_num, :desc_us_long], "#{file_prefix}_lu_month_in_year.csv") do |item|
      [[
        item[1],
        # TODO fix the possible changes in what is a first week
        "#{Date::ABBR_MONTHNAMES[item[1]]}",
        "M#{item[1]}/Q#{item[0]}",
        "M#{item[1]}",
        "#{Date::MONTHNAMES[item[1]]}"
      ]]
    end

    # Days Of Week
    save_as_csv(aggregate_on(weeks, Day), [:id, :descr_default, :desc_num, :desc_us_long], "#{file_prefix}_lu_day_in_week.csv") do |item|
      first_day_index = Date::ABBR_DAYNAMES.index(@first_day_of_week) - 1
      puts item
      [[
        item,
        "#{Date::ABBR_DAYNAMES[(item + first_day_index) % 7 ]}",
        "#{item}",
        "#{Date::DAYNAMES[(item + first_day_index) % 7 ]}"
      ]]
    end
    end
  end
end