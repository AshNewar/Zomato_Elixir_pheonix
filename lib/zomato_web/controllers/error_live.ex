defmodule ZomatoWeb.ErrorLive do
  use ZomatoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center h-screen bg-gray-100">
      <div class="text-center">
        <h1 class="text-6xl font-bold text-gray-800 mb-4">404</h1>
        <p class="text-2xl text-gray-600 mb-8">Oops! Page not found.</p>
        <p class="text-gray-500 mb-8">The page you’re looking for doesn’t exist.</p>
        <a href="/" class="inline-block bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-700 transition-colors">
          Go to Homepage
        </a>
      </div>
    </div>
    """
  end
end
