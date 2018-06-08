# name: search index api
# about: provides an api to be able to query for posts for indexing
# version: 0.1
# authors: Genesys Dev Evangelists

PLUGIN_NAME ||= 'search_index_content'.freeze
PAGE_SIZE = 200

INDEX_CATEGORIES = [
    20, # Announcements
    5,  # Platform API
    12, # PureCloud Webhooks
    13, # Bridge Server/Data Actions
    14, # PureCloud Web Chat
    15, # PureCloud Integrations
    21, # PureCloud Applications
    18, # Developer Tools
    16, # Coffee House
    19, # API Enhancement Requests
    1,  # Uncategorized
]

after_initialize do

    module ::DiscourseSearchIndex
        class Engine < ::Rails::Engine
            engine_name PLUGIN_NAME
            isolate_namespace DiscourseSearchIndex
        end
    end

    require_dependency 'application_controller'

    class DiscourseSearchIndex::SearchIndexController < ::ApplicationController
        requires_plugin PLUGIN_NAME

        def on_request
            params.permit(:page)
            page = params[:page].to_i

            page = 1 if page == 0

            offset = ((page - 1) * PAGE_SIZE) 
            return_list = []

            posts = Post.public_posts
                    .where(deleted_at: nil)
                    .where("topics.category_id IN (#{INDEX_CATEGORIES.join(',')})")
                    .order(created_at: :desc)
                    .limit(PAGE_SIZE).offset(offset)

            #

            for post in posts 
                 detail = {
                     :id => post.id,
                     :topicId => post.topic_id,
                     :url =>  "/forum/#{post.url}",
                     :categoryId => post.topic.category_id,
                     :title => post.topic.title,
                     :content => post.raw.gsub(/\n/,' ') #remove newline
                                    .gsub(/:[\w_]+:/,' ') #emoji
                                    .gsub(/[\*#~\-_|:\[\]\(\)\{\}]/,' ') #remove astricks and markdown
                 }
                 
                 return_list.push detail
                
            end       
                             
            response = {
                :results => return_list,
                :page => page
            }
            render json: response
            
        end
    end

    DiscourseSearchIndex::Engine.routes.draw do
        get '/list' => 'search_index#on_request'
    end

    ::Discourse::Application.routes.append do
        mount ::DiscourseSearchIndex::Engine, at: '/searchindex'
    end   
end
