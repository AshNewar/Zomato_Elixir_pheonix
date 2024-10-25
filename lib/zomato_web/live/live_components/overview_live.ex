defmodule ZomatoWeb.LiveComponents.OverviewLive do
  use ZomatoWeb, :live_component

  def render(assigns) do
    ~H"""
      <div id="overview" class="section mt-8">
        <%!-- <h2 class="text-2xl font-bold mb-4">Overview</h2>
        <p class="text-gray-700 mb-4">This is the overview section. Here you'll find general information about the restaurant.</p> --%>

        <h3 class="text-xl font-semibold mb-2">About</h3>
        <div class="flex flex-wrap gap-2 mb-4">
          <span class="bg-blue-100 text-blue-800 text-sm font-semibold px-4 py-2 rounded-lg">Best Place to Eat</span>
          <span class="bg-blue-100 text-blue-800 text-sm font-semibold px-4 py-2 rounded-lg">No Noise</span>
          <span class="bg-blue-100 text-blue-800 text-sm font-semibold px-4 py-2 rounded-lg">Good Food</span>
        </div>

        <h3 class="text-xl font-semibold mb-2">Cuisine</h3>
        <div class="flex flex-wrap gap-2 mb-4">
          <span class="bg-green-100 text-green-800 text-sm font-semibold px-4 py-2 rounded-lg">North Indian</span>
          <span class="bg-green-100 text-green-800 text-sm font-semibold px-4 py-2 rounded-lg">South Indian</span>
          <span class="bg-green-100 text-green-800 text-sm font-semibold px-4 py-2 rounded-lg">Chinese</span>
        </div>

        <h3 class="text-xl font-semibold mb-2">Popular Dishes</h3>
        <div class="flex flex-wrap gap-2">
          <span class="bg-yellow-100 text-yellow-800 text-sm font-semibold px-4 py-2 rounded-lg">Paneer Butter Masala</span>
          <span class="bg-yellow-100 text-yellow-800 text-sm font-semibold px-4 py-2 rounded-lg">Chicken Biryani</span>
        </div>
      </div>

    """

  end

end
