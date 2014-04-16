require 'csv'
CSV_FILENAME = "coviolators.csv"

class CoViolator
  def initialize (filename)
    @fn = filename
    unless File.exists?(@fn)
      raise "No such file as {#@fn}\n"
    end
    @pair_counts = Hash.new(0) #count of all pairings
    @cite_counts = Hash.new(0) #count of times each section is cited
  end

  # process the file into hash keyed by an array representing the pairs
  def process
    File.open(@fn, "r").each_line do |line|
      # clean up cruft
      # split and go
      # sorting is done to ensure that combination pairings are in same order throughout. This may not work.
      next if line =~ /^Section/
      line.chomp!.gsub!(/"/, '')
      breakout = line.split(',')
      breakout.sort!
      breakout.each { |cite| @cite_counts[cite] = @cite_counts[cite] + 1 }
      combos = breakout.combination(2).to_a
      combos.each do |combo|
        @pair_counts[combo] = @pair_counts[combo] + 1
      end
    end
    # sort the hash by count
    @pair_counts = Hash[@pair_counts.sort_by { |key, value| value }.reverse]
    puts('blah')
  end

  def make_csv
    CSV.open(CSV_FILENAME, "wb") do |csv|
      csv << ["Violation 1", "Violation 2", "Count", "V1 pct", "V2 pct"]
      @pair_counts.each do |key, count|
        v1pct = (count * 100 /@cite_counts[key[0]])
        v2pct = (count * 100 /@cite_counts[key[1]])
        csv << [key[0].to_s, key[1].to_s, count.to_s, v1pct.to_s, v2pct.to_s]
      end
    end
  end
end

# just do it.
grinder = CoViolator.new('/home/tom/Dropbox/FMCSA/allfmcsa.csv')
grinder.process
grinder.make_csv

