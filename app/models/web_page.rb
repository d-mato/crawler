class WebPage < ApplicationRecord
  belongs_to :crawler_job, counter_cache: :web_pages_count

  has_one_attached :html

  def fetched?
    fetched_at? && html.attached?
  end

  def fetch_contents
    html.attach(io: open(url), filename: 'html')
    touch :fetched_at
  rescue => e
    update!(error_message: e.message)
  end

  # @override
  def inspect
    inspection = if defined?(@attributes) && @attributes
      self.class.attribute_names.collect do |name|
        if has_attribute?(name)
          "#{name}: #{attribute_for_inspect(name)}"
        end
      end.compact.join(", ")
    else
      "not initialized"
    end

    "#<#{self.class} #{inspection}>"
  end
end
