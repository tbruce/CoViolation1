CSV_FILENAME = "coviolators.csv"

class CoViolator
  def initialize (filename)
    @fn = filename
    unless exists?(@fn)
      raise "No such file as {#@fn}\n"
    end
    @pair_counts = Hash.new(0) #count of all pairings
  end

  # process the file into hash keyed by an array representing the pairs
  def process
    File.open(@fn, "r").each_line do |line|
      # clean up cruft
      # split and go
      # sorting is done to ensure that combination pairings are in same order throughout. This may not work.
      combos = line.split(',').sort!.combination(2).to_a
      combos.each do |combo|
        @pair_counts[combo] = @pair_counts[combo] + 1
      end
    end
    # sort the hash by count
    @pair_counts.sort_by { |_key, value| value }.reverse!
  end

  def make_csv
    CSV.open(CSV_FILENAME, "wb") do |csv|
      csv << ["Violation 1", "Violation 2", "Count"]
      @pair_counts.each do |key, count|
        csv << [key[0].to_s, key[1].to_s, count.to_s]
      end
    end
  end

  # just do it.
  grinder = CoViolator.new('/home/tom/Dropbox/FMCSA/2013.csv')
  grinder.process
