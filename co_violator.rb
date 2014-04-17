require 'csv'
CSV_FILENAME_BASE = "coviolators"

class CoViolator
  def initialize (filename)
    @fn = filename
    unless File.exists?(@fn)
      raise "No such file as #{@fn}\n"
    end
  end

  # process the file into hash keyed by an array representing the pairs
  def process
    # process for all arities
    @combo_counts = Hash.new(0) #count of all pairings
    @cite_counts = Hash.new(0) #count of times each section is cited
    arity = 1
    while arity > 0
      arity = arity + 1
      f = File.open(@fn, "r")
      f.each_line do |line|
        # clean up cruft
        # split and go
        # sorting is done to ensure that combination pairings are in same order throughout. This may not work.
        next if line =~ /^Section/
        line.chomp!.gsub!(/"/, '')
        breakout = line.split(',')
        # turns out that sometimes there are duplicated entries
        breakout.sort!.uniq!
        breakout.each { |cite| @cite_counts[cite] = @cite_counts[cite] + 1 }
        combos = breakout.combination(arity).to_a
        if combos.length > 0
          combos.each do |combo|
            @combo_counts[combo] = @combo_counts[combo] + 1
          end
        end
      end
      f.close
      exit if @combo_counts.length < 1
      # sort the hash by count
      @combo_counts = Hash[@combo_counts.sort_by { |key, value| value }.reverse]
      make_csv(arity)
      @combo_counts.clear
      @cite_counts.clear
      @combo_counts.default = 0
      @cite_counts.default = 0
    end
  end

  def make_csv(arity)
    CSV.open(CSV_FILENAME_BASE + "#{arity}.csv", "wb") do |csv|
      colheader = Array.new
      for n in 1..arity do
        colheader.push("Violation #{n}")
      end
      colheader.push("Count")
      for n in 1..arity do
        colheader.push("V#{n} pct")
      end
      colheader.push("Narrative")
      csv << colheader
      @combo_counts.each do |key, count|
        row = Array.new
        for n in 0..arity-1 do
          row.push(key[n].to_s)
        end
        row.push(count)
        for n in 0..arity-1 do
          row.push(count * 100 / @cite_counts[key[n]])
        end
        row.push(" ")
        csv << row
      end
    end
  end
end

# just do it.
grinder = CoViolator.new('/home/tom/Dropbox/FMCSA/allfmcsa.csv')
grinder.process


