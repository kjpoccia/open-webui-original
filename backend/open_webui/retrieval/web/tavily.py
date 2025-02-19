import logging
from typing import Optional

import requests
from open_webui.retrieval.web.main import SearchResult, get_filtered_results, SearchParameters
from open_webui.env import SRC_LOG_LEVELS

log = logging.getLogger(__name__)
log.setLevel(SRC_LOG_LEVELS["RAG"])


def search_tavily(
    params : SearchParameters,
    api_key : str,
    # **kwargs,
) -> list[SearchResult]:
    """Search using Tavily's Search API and return the results as a list of SearchResult objects.

    Args:
        api_key (str): A Tavily Search API key
        query (str): The query to search for
        count (int): The maximum number of results to return

    Returns:
        list[SearchResult]: A list of search results
    """
    url = "https://api.tavily.com/search"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    data = {"query": query, "max_results": count}
    response = requests.post(url, headers=headers, json=data)
    data = {"query": params.query, "api_key": api_key}
    response = requests.post(url, json=data)
    response.raise_for_status()

    json_response = response.json()

    results = json_response.get("results", [])
    if filter_list:
        results = get_filtered_results(results, filter_list)

    return [
        SearchResult(
            link=result["url"],
            title=result.get("title", ""),
            snippet=result.get("content"),
        )
        for result in results
    ]
