# name: search index api
# about: provides an api to be able to query for posts for indexing
# version: 0.1
# authors: Genesys Dev Evangelists

PLUGIN_NAME ||= 'search_index_content'.freeze
PAGE_SIZE = 100

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

            offset = ((page - 1) * PAGE_SIZE) 
            posts = Post.public_posts
                    .order(created_at: :desc)
                    .limit(PAGE_SIZE).offset(offset)

            return_list = []

            for post in posts 
                 detail = {
                     :id => post.id,
                     :url => post.url,
                     :content => post.cooked
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
