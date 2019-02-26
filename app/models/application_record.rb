class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_initialize do
    # not nullなtext型に空文字を設定
    self.class.columns.each do |column|
      if column.type == :text && column.null == false
        self[column.name] ||= ''
      end
    end
  end
end
