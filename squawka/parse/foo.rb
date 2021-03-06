#!/usr/bin/env ruby
# coding: utf-8

require "csv"
require "nokogiri"

require "cgi"

args = ARGV
dir = args[0]

print "Target dir is #{dir}\n"

if (args[1..-1].size==1) and (args[1].include?('*'))
  print "No xml files to process; skipping.\n"
  exit
end

if not(File.directory?(dir))
  print "Target csv directory missing; skipping.\n"
  exit
end

games = CSV.open("#{dir}/games.csv", "w")
teams = CSV.open("#{dir}/teams.csv", "w")
players = CSV.open("#{dir}/players.csv", "w")
periods = CSV.open("#{dir}/periods.csv", "w")
time_slices = CSV.open("#{dir}/time_slices.csv", "w")
team_possessions = CSV.open("#{dir}/team_possessions.csv", "w")
swaps = CSV.open("#{dir}/swaps.csv", "w")
players_in_grounds = CSV.open("#{dir}/players_in_grounds.csv", "w")
ts_players = CSV.open("#{dir}/ts_players.csv", "w")
player_inf_scores = CSV.open("#{dir}/player_inf_scores.csv", "w")

# Filters

# goal_keeping

goal_keeping_events = CSV.open("#{dir}/goal_keeping_events.csv", "w")
goal_keeping_results = CSV.open("#{dir}/goal_keeping_results.csv", "w")

# goals_attempts

goals_attempts_events = CSV.open("#{dir}/goals_attempts_events.csv", "w")
goals_attempts_results = CSV.open("#{dir}/goals_attempts_results.csv", "w")
goals_assists = CSV.open("#{dir}/goals_assists.csv", "w")
goals_passes = CSV.open("#{dir}/goals_passes.csv", "w")

# action_areas

aa_teams = CSV.open("#{dir}/aa_teams.csv", "w")
aa_players = CSV.open("#{dir}/aa_players.csv", "w")

# headed_duals
# interceptions
# clearances
# all_passes
# tackles
# crosses
# corners
# offside
# keepersweeper
# oneonones
# setpieces
# takeons
# fouls
# cards
# blocked_events
# extra_heat_maps
# balls_out

args[1..-1].each do |file|

  file_name = File.basename(file)
  game_id = file_name.split(".")[0]

  print("parsing #{game_id}\n")

  #game_id = File.dirname(file).split("/")[-1]
  #league_key = File.dirname(file).split("/")[-2]
  #print "Parsing #{game_id} ...\n"

  begin
    xml = Nokogiri::XML(File.open(file))
  rescue
    next
  end

  xml.search("/squawka").each do |squawka|

    date = squawka.attribute("date").value rescue nil
    time = squawka.attribute("time").value rescue nil
    timezone = squawka.attribute("timezone").value rescue nil
    data_freshness = squawka.attribute("data_freshness").value rescue nil

    xml.search("data_panel").each do |data_panel|

      system = data_panel.search("system").first rescue nil
      
      headline = system.search("headline").first.inner_text rescue nil
      refresh_rate = system.search("refresh_rate").first.inner_text rescue nil
      state = system.search("state").first.inner_text rescue nil
      show_ingame_rdp = system.search("show_ingame_rdp").first.inner_text rescue nil

      data_panel.search("game").each do |game|

        name = game.search("name").first.inner_text rescue nil
        venue = game.search("venue").first.inner_text rescue nil
        kickoff = game.search("kickoff").first.inner_text rescue nil
        timeleft = game.search("timeleft").first.inner_text rescue nil
        competition_name = game.search("competition_name").first.inner_text rescue nil

        games << [game_id, date, time, timezone, data_freshness,
                  state, headline, refresh_rate, show_ingame_rdp,
                  venue, kickoff, timeleft, competition_name]
      
        game.search("team").each do |team|
        
          team_id = team.attribute("id").value rescue nil
          long_name = team.search("long_name").first.inner_text rescue nil
          short_name = team.search("short_name").first.inner_text rescue nil
          logo = team.search("logo").first.inner_text rescue nil
          shirt_url = team.search("shirt_url").first.inner_text rescue nil
          club_url = team.search("club_url").first.inner_text rescue nil
          state = team.search("state").first.inner_text rescue nil
          team_color = team.search("team_color").first.inner_text rescue nil

          teams << [game_id, team_id, long_name, short_name, logo, shirt_url,
                    club_url, state, team_color]
        
        end

      end

      data_panel.search("players/player").each do |player|
        
        player_id = player.attribute("id").value rescue nil
        team_id = player.attribute("team_id").value rescue nil
        
        first_name = player.search("first_name").first.inner_text rescue nil
        last_name = player.search("last_name").first.inner_text rescue nil
        name = player.search("name").first.inner_text rescue nil
        surname = player.search("surname").first.inner_text rescue nil
        team_name = player.search("team_name").first.inner_text rescue nil
        photo = player.search("photo").first.inner_text rescue nil
        position = player.search("position").first.inner_text rescue nil
        dob = player.search("dob").first.inner_text rescue nil
        weight = player.search("weight").first.inner_text rescue nil
        height = player.search("height").first.inner_text rescue nil
        shirt_num = player.search("shirt_num").first.inner_text rescue nil
        total_influence = player.search("total_influence").first.inner_text rescue nil
        country = player.search("country").first.inner_text rescue nil
        profile_url = player.search("profile_url").first.inner_text rescue nil
        x_loc = player.search("x_loc").first.inner_text rescue nil
        y_loc = player.search("y_loc").first.inner_text rescue nil
        state = player.search("state").first.inner_text rescue nil
        age = player.search("age").first.inner_text rescue nil
        bmi = player.search("bmi").first.inner_text rescue nil

        players << [game_id, player_id, team_id,
                    first_name, last_name, name, surname,
                    team_name, photo, position, dob, weight, height,
                    shirt_num, total_influence, country, profile_url,
                    x_loc, y_loc, state, age, bmi]
        
      end

      data_panel.search("possession/period").each do |period|

        period_id = period.attribute("id").value rescue nil

        period.search("play_direction").each do |play_direction|
          
          team_id = play_direction.attribute("team_id").value rescue nil
          play_direction_text = play_direction.inner_text rescue nil
          
          periods << [game_id, period_id, team_id, play_direction_text]
          
        end

        period.search("time_slice").each do |time_slice|

          time_slice_name = time_slice.attribute("name").value rescue nil
          time_slice_id = time_slice.attribute("id").value rescue nil
          scored_min = time_slice.attribute("scored_min").value rescue nil

          time_slices << [game_id, period_id,
                          time_slice_name, time_slice_id,
                          scored_min]

          time_slice.search("team_possession").each do |team_possession|
            
            team_id = team_possession.attribute("team_id").value rescue nil
            team_possession_text = team_possession.inner_text rescue nil
            
            team_possessions << [game_id, period_id,
                                 time_slice_name, time_slice_id,
                                 scored_min,
                                 team_id, team_possession_text]
          end

          time_slice.search("swap_players").each do |swap_players|

            team_id = swap_players.attribute("team_id").value rescue nil
            min = swap_players.attribute("min").value rescue nil
            minsec = swap_players.attribute("minsec").value rescue nil

            sub_to_player = swap_players.search("sub_to_player").first rescue nil
            sub_to_player_id = sub_to_player.attribute("player_id").value rescue nil
            sub_to_player_name = sub_to_player.text rescue nil
            
            player_to_sub = swap_players.search("player_to_sub").first rescue nil
            player_to_sub_id = player_to_sub.attribute("player_id").value rescue nil
            player_to_sub_name = player_to_sub.text rescue nil
            
            swaps << [game_id, period_id,
                      time_slice_name, time_slice_id,
                      scored_min,
                      team_id, min, minsec,
                      sub_to_player_id, sub_to_player_name,
                      player_to_sub_id, player_to_sub_name]

          end

          time_slice.search("players_in_ground").each do |players_in_ground|
            
            injurytime_play = players_in_ground.attribute("injurytime_play").value rescue nil

            players_in_grounds << [game_id, period_id,
                                   time_slice_name, time_slice_id,
                                   scored_min,
                                   injurytime_play]
            
            players_in_ground.search("ts_player").each do |ts_player|
              
              ts_player_id = ts_player.attribute("id").value rescue nil
              team_id = ts_player.attribute("team_id").value rescue nil
              first_name = ts_player.search("first_name").first.text rescue nil
              player_name = ts_player.search("name").first.text rescue nil
              team_name = ts_player.search("team_name").first.text rescue nil
              photo = ts_player.search("photo").first.text rescue nil
              dob = ts_player.search("dob").first.text rescue nil
              weight = ts_player.search("weight").first.text rescue nil
              height = ts_player.search("height").first.text rescue nil
              shirt_num = ts_player.search("shirt_num").first.text rescue nil
              total_influence = ts_player.search("total_influence").first.text rescue nil
              profile_url = ts_player.search("profile_url").first.text rescue nil
              country = ts_player.search("country").first.text rescue nil
              position = ts_player.search("position").first.text rescue nil
              state = ts_player.search("state").first.text rescue nil
              x_loc = ts_player.search("x_loc").first.text rescue nil
              y_loc = ts_player.search("y_loc").first.text rescue nil

              ts_players << [game_id, period_id,
                             time_slice_name, time_slice_id,
                             scored_min,
                             ts_player_id, team_id,
                             first_name, player_name, team_name,
                             photo, dob, weight, height, shirt_num,
                             total_influence, profile_url,
                             country, position, state,
                             x_loc, y_loc]
            end

          end

          time_slice.search("player_inf_score").each do |player_inf_score|

            #<player_inf_score id="411" possession="2.32" attack="0" defense="5.39" goalkeeping="0" injurytime_play="0">7.71</player_inf_score>

            player_inf_score_id = player_inf_score.attribute("id").value rescue nil
            possession = player_inf_score.attribute("possession").value rescue nil
            attack = player_inf_score.attribute("attack").value rescue nil
            defense = player_inf_score.attribute("defense").value rescue nil
            goalkeeping = player_inf_score.attribute("goalkeeping").value rescue nil
            injurytime_play = player_inf_score.attribute("injurytime_play").value rescue nil
            player_inf_score_text = player_inf_score.text rescue nil

            player_inf_scores << [game_id, period_id,
                                  time_slice_name, time_slice_id,
                                  scored_min,
                                  player_inf_score_id,
                                  possession, attack, defense,
                                  goalkeeping, injurytime_play,
                                  player_inf_score_text]

          end

        end

      end

      # goal_keeping

      data_panel.search("filters/goal_keeping/time_slice").each do |time_slice|

        time_slice_name = time_slice.attribute("name").value rescue nil
        time_slice_id = time_slice.attribute("id").value rescue nil

        time_slice.search("event").each do |event|

          event_type = event.attribute("type").value rescue nil
          player_id = event.attribute("player_id").value rescue nil
          team_id = event.attribute("team_id").value rescue nil
          action_type = event.attribute("action_type").value rescue nil
          mins = event.attribute("mins").value rescue nil
          secs = event.attribute("secs").value rescue nil
          minsec = event.attribute("minsec").value rescue nil
          headed = event.attribute("headed").value rescue nil

          event_text = event.text rescue nil

          goal_keeping_events << [game_id,
                                  time_slice_name, time_slice_id,
                                  event_type, player_id, team_id,
                                  action_type, mins, secs, minsec,
                                  headed, event_text]
        end

        time_slice.search("gk_result").each do |gk_result|

          team_id = gk_result.attribute("team_id").value rescue nil
          saves = gk_result.attribute("saves").value rescue nil
          punches = gk_result.attribute("punches").value rescue nil
          catches = gk_result.attribute("catches").value rescue nil
          failed_catches = gk_result.attribute("failed_catches").value rescue nil
          clearances = gk_result.attribute("clearances").value rescue nil
          failedclearances = gk_result.attribute("failedclearances").value rescue nil

          goal_keeping_results << [game_id,
                                   time_slice_name, time_slice_id,
                                   team_id,
                                   saves, punches,
                                   catches, failed_catches,
                                   clearances, failedclearances]

        end

      end

      # goals_attempts

      data_panel.search("filters/goals_attempts/time_slice").each do |time_slice|

        time_slice_name = time_slice.attribute("name").value rescue nil
        time_slice_id = time_slice.attribute("id").value rescue nil
        attempts_count = time_slice.attribute("attempts_count").value rescue nil

        #<event type="off_target" player_id="922" team_id="39" action_type="Attack" mins="1" secs="53" minsec="113">
        #<event type="blocked" player_id="11524" team_id="514" action_type="Attack" mins="4" secs="59" minsec="299">
        #<event type="goal" player_id="5493" team_id="39" action_type="Attack" mins="18" secs="54" minsec="1134" uid="1907116946">
        #<assist_1 x="56.4" y="18" x2="79.0" y2="54.8" min="18">922</assist_1>
        #<passlinks>[{"type":"failed_pass","sub_type":"","swere":"","period":"1","headed":0,"start_x":67.7,"start_y":91.6,"end_x":63.7,"end_y":97.3,"club_id":"39","player_id":"10182","player_name":"Matt Ritchie","photo":"uploaded_icons\/players\/thumb\/p10182c299j30.jpg","side":"away","min":"18","sec":"40","minsec":"1120"},]</passlinks>

        time_slice.search("event").each do |event|

          event_type = event.attribute("type").value rescue nil
          player_id = event.attribute("player_id").value rescue nil
          team_id = event.attribute("team_id").value rescue nil
          action_type = event.attribute("action_type").value rescue nil
          mins = event.attribute("mins").value rescue nil
          secs = event.attribute("secs").value rescue nil
          minsec = event.attribute("minsec").value rescue nil
          
          uid = event.attribute("uid").value rescue nil

          case event_type
          when "goal"

            #<assist_1 x="56.4" y="18" x2="79.0" y2="54.8" min="18">922</assist_1>
            assist = event.search("assist_1").first rescue nil
            
            if not(assist==nil)
              
              assist_x = assist.attribute("x").value rescue nil
              assist_y = assist.attribute("y").value rescue nil
              assist_x2 = assist.attribute("x2").value rescue nil
              assist_y2 = assist.attribute("y2").value rescue nil
              assist_min = assist.attribute("min").value rescue nil
              assist_text = assist.text rescue nil

              goals_assists << [game_id,
                                time_slice_name, time_slice_id,
                                event_type, player_id, team_id,
                                action_type, mins, secs, minsec,
                                uid,
                                assist_x, assist_y,
                                assist_x2, assist_y2,
                                assist_min,
                                assist_text]
              
            end

            passlinks = event.search("passlinks").first rescue nil

            if not(passlinks==nil)
              
              passes = passlinks.text rescue nil

              goals_passes << [passes]

            end

          end

          #<passlinks>

          event_start = event.search("start").first.text rescue nil
          event_middle = event.search("middle").first.text rescue nil
          event_end = event.search("end").first.text rescue nil
          event_swere = event.search("swere").first.text rescue nil
          
          # <coordinates start_x="97.6" start_y="39.8" end_x="98.8" end_y="42.2" gmouth_y="49.3" gmouth_z="1.3"/>
          
          event_coordinates = event.search("coordinates").first rescue nil
          event_start_x = event_coordinates.attribute("start_x").value rescue nil
          event_start_y = event_coordinates.attribute("start_y").value rescue nil
          event_end_x = event_coordinates.attribute("end_x").value rescue nil
          event_end_y = event_coordinates.attribute("end_y").value rescue nil
          event_gmouth_y = event_coordinates.attribute("gmouth_y").value rescue nil
          event_gmouth_z = event_coordinates.attribute("gmouth_z").value rescue nil
          
          event_shot = event.search("shot").first.text rescue nil

          goals_attempts_events << [game_id,
                                    time_slice_name, time_slice_id,
                                    event_type, player_id, team_id,
                                    action_type, mins, secs, minsec,
                                    uid,
                                    event_start, event_middle, event_end,
                                    event_swere,
                                    event_start_x, event_start_y,
                                    event_end_x, event_end_y,
                                    event_gmouth_y, event_gmouth_z,
                                    event_shot]
        end
        
        #<ga_result team_id="47" goal="0" save="0" off_target="1" blocked="0" wood_work="0" headed="0" shot="0">0/1</ga_result>

        time_slice.search("ga_result").each do |ga_result|

          team_id = ga_result.attribute("team_id").value rescue nil
          goal = ga_result.attribute("goal").value rescue nil
          save = ga_result.attribute("save").value rescue nil
          off_target = ga_result.attribute("off_target").value rescue nil
          blocked = ga_result.attribute("blocked").value rescue nil
          wood_work = ga_result.attribute("wood_work").value rescue nil
          headed = ga_result.attribute("headed").value rescue nil
          shot = ga_result.attribute("shot").value rescue nil
          ga_result_text = ga_result.text rescue nil

          goals_attempts_results << [game_id,
                                     time_slice_name, time_slice_id,
                                     team_id,
                                     save, off_target, blocked,
                                     wood_work, headed, shot,
                                     ga_result_text]

        end

      end

      #<action_areas>
      #  <action_area id="11">
      #    <aa_team id="39">4</aa_team>
      #    <aa_player id="922" team_id="39">1</aa_player>

      # action_areas

      data_panel.search("filters/action_areas/time_slice").each do |time_slice|

        time_slice_name = time_slice.attribute("name").value rescue nil
        time_slice_id = time_slice.attribute("id").value rescue nil

        time_slice.search("action_area").each do |action_area|

          action_area_id = action_area.attribute("id").value rescue nil
          injurytime_play = action_area.attribute("injurytime_play").value rescue nil

          action_area.search("aa_team").each do |aa_team|
            aa_team_id = aa_team.attribute("id").value rescue nil
            aa_team_value = aa_team.text

            aa_teams << [game_id,
                         time_slice_name, time_slice_id,
                         action_area_id, injurytime_play,
                         aa_team_id, aa_team_value]
          end

          action_area.search("aa_player").each do |aa_player|
            aa_player_id = aa_player.attribute("id").value rescue nil
            aa_team_id = aa_player.attribute("team_id").value rescue nil
            aa_player_value = aa_player.text

            aa_players << [game_id,
                           time_slice_name, time_slice_id,
                           action_area_id, injurytime_play,
                           aa_player_id, aa_team_id, aa_player_value]
          end

        end

      end

      # headed_duals

      # time_slice
      # event
      # loc
      # otherplayer
      # hd_result

      #data_panel.search("filters/headed_duals/time_slice").each do |time_slice|
      #end

    end

  end
    
end
