class DailySummaryAccount < ActiveRecord::Base
  establish_connection "log_db_#{Rails.env}"
  attr_accessible :promotion_id, :media_category_id, :cost_per_click,
    :account_id, :media_id, :imp_count, :click_count, :cost_sum,
    :click_through_ratio, :report_ymd, :create_time, :cost_per_mille
  
  def self.get_table_data promotion_id, start_date, end_date, language = I18n.t("time_format")
    results = Hash.new
    array_result = Hash.new
    start_date = Date.strptime(start_date, language).strftime("%Y/%m/%d")
    end_date = Date.strptime(end_date, language).strftime("%Y/%m/%d")
    total_promotion_data = DailySummaryAccount.where(promotion_id: promotion_id)
      .where("DATE_FORMAT(report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
      .select("sum(imp_count) as imp_count")
      .select("sum(click_count) as click_count")
      .select("round(sum(click_count)/sum(imp_count)*100,3) as click_through_ratio")
      .select("sum(cost_sum) as cost_sum")
      .select("round(sum(cost_sum)/sum(click_count),3) as cost_per_click")
      .select("round(sum(cost_sum)/sum(imp_count)*1000,3) as cost_per_mille")
      .select(:media_category_id)
      
    category_promotion_data = total_promotion_data.group(:media_category_id)
    
    promotion_data = total_promotion_data.group(:account_id).select(:account_id)
    
    chart_promotion_data = total_promotion_data.select(:report_ymd).group(:report_ymd) 
    
    total_conversions_data = DailySummaryAccConversion.where(promotion_id: promotion_id)
      .group(:conversion_id).select("sum(total_cv_count) as total_cv_count")
      .select("sum(first_cv_count) as first_cv_count")
      .select("sum(repeat_cv_count) as repeat_cv_count")
      .select("sum(assist_count) as assist_count")
      .select("sum(sales) as sales")
      .select("sum(profit) as profit")
      .select(:conversion_id)
      .where("DATE_FORMAT(daily_summary_acc_conversions.report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
      .select(:report_ymd)
      
    conversions_data = total_conversions_data.group(:account_id).select(:account_id)
    
      
    begin
      promotion_conversions_data = connection.select_all("select table1.account_id, table1.conversion_id, " +
        "table1.total_cv_count, table1.first_cv_count, table1.repeat_cv_count, " +
        "table1.assist_count, table1.sales, table1.profit, " +
        "round(total_cv_count/click_count*100,1) as conversion_rate, " +
        " round(cost_sum/total_cv_count,3) as click_per_action, round(sales/cost_sum*100,3) as roas, round((profit-cost_sum)/cost_sum*100,3) as roi" +
        " from (#{conversions_data.to_sql}) as table1 left join (#{promotion_data.to_sql}) as table2 on table1.account_id=table2.account_id")

      category_conversions_data = connection.select_all("select table1.conversion_id, table2.media_category_id, " +
        "sum(total_cv_count) as total_cv_count, " +
        "sum(first_cv_count) as first_cv_count, " +
        "sum(repeat_cv_count) as repeat_cv_count, " +
        "sum(assist_count) as assist_count, " +
        "sum(sales) as sales, " +
        "sum(profit) as profit, " +
        "round(sum(total_cv_count)/table5.click_count*100,1) as conversion_rate, " +
        "round(table5.cost_sum/sum(total_cv_count),3) as click_per_action, " +
        "round(sum(sales)/table5.cost_sum*100,3) as roas, " +
        "round((sum(profit)-table5.cost_sum)/table5.cost_sum*100,3) as roi " +
        " from (#{conversions_data.to_sql}) as table1 left join (#{promotion_data.to_sql}) as table2 on table1.account_id=table2.account_id left join (#{category_promotion_data.to_sql}) as table5 on table5.media_category_id=table2.media_category_id  " +
        " group by table1.conversion_id, table2.media_category_id")
      
      total_conversions = connection.select_all("select table4.conversion_id, " +
        "round(total_cv_count/click_count*100,1) as conversion_rate, " +
        "round(cost_sum/total_cv_count,3) as click_per_action, " +
        "round(sales/cost_sum*100,3) as roas, " +
        "round((profit-cost_sum)/cost_sum*100,3) as roi, " +
        "total_cv_count, " +
        "first_cv_count, " +
        "repeat_cv_count, " +
        "assist_count, " +
        "sales, " +
        "profit, table4.report_ymd" +
        " from (#{total_promotion_data.to_sql}) as table3 join (#{total_conversions_data.to_sql}) as table4")
        
      chart_conversions = connection.select_all("select table4.conversion_id, " +
        "round(total_cv_count/click_count*100,1) as conversion_rate, " +
        "round(cost_sum/total_cv_count,3) as click_per_action, " +
        "round(sales/cost_sum*100,3) as roas, " +
        "round((profit-cost_sum)/cost_sum*100,3) as roi, " +
        "total_cv_count, " +
        "first_cv_count, " +
        "repeat_cv_count, " +
        "assist_count, " +
        "sales, " +
        "profit, table4.report_ymd" +
        " from (#{chart_promotion_data.to_sql}) as table3 join (#{total_conversions_data.group(:report_ymd).to_sql}) as table4 on table3.report_ymd=table4.report_ymd" +
        " group by table4.report_ymd, table4.conversion_id")
        
      promotion_conversions_data.each do |data|
        results["account"+data["account_id"].to_s+"_conversion" + data["conversion_id"].to_s] = data
      end
      
      promotion_data.each do |data|
        results["account"+ data.account_id.to_s + "_promotion"] = data
      end
      
      category_conversions_data.each do |data|
        results[Settings.media_category[data["media_category_id"]]+ "_conversion" + data["conversion_id"].to_s+ "_total"] = data
      end
      
      category_promotion_data.each do |data|
        results[Settings.media_category[data["media_category_id"]] + "_total"] = data
      end
      
      results["total_promotion"] = total_promotion_data[0]
      
      total_conversions.each do |data|
        results["total_conversion" + data["conversion_id"].to_s] = data
      end
      
      results["total_promotion"] = total_promotion_data[0]
     
      date_range = Array.new
      (start_date.to_date..end_date.to_date).each do |date|
        date_range << date.to_date.strftime("%Y/%m/%d")
      end
      
      Settings.promotions_options.each do |option|
        array_result[option] = Array.new  
      end
      
      total_conversions.each do |conversion|
        Settings.conversions_graph.each do |option|
          array_result["#{conversion["conversion_id"]}_#{option}"] = Array.new
        end
      end

      date_range.each do |datetime|
        if chart_promotion_data.length == 0
          Settings.promotions_options.each do |option|
            array_result[option] << 0  
          end
        else
          count = 0
          chart_promotion_data.each do |val|
            if(val["report_ymd"] && val["report_ymd"].to_s.to_date.strftime("%Y/%m/%d") == datetime)
              count += 1
              Settings.promotions_options.each_with_index do |option, index|
                array_result[option] << val[Settings.promotions_sums[index]] ? val[Settings.promotions_sums[index]] : 0
              end
            end
          end
        end
        if count == 0
          Settings.promotions_options.each_with_index do |option, index|
            array_result[option] << 0
          end
        end
        
        total_conversions.each do |conversion1|
          conversion1_id = conversion1["conversion_id"]
          count = 0
          chart_conversions.each do |conversion|
            conversion_id = conversion["conversion_id"]
            next if conversion1_id != conversion_id
            if(conversion["report_ymd"] && conversion["report_ymd"].to_s.to_date.strftime("%Y/%m/%d") == datetime)
              count += 1
              Settings.conversions_graph.each_with_index do |option, index|
                array_result["#{conversion["conversion_id"]}_#{option}"] << conversion[Settings.conversions_sums[index]] ? conversion[Settings.conversions_sums[index]] : 0
              end
            end
          end
          if count == 0
            Settings.conversions_graph.each_with_index do |option, index|
              array_result["#{conversion1["conversion_id"]}_#{option}"] << 0
            end
          end
        end
      end
    end
    return results, array_result, date_range
  end
end