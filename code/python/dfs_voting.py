import heapq
from typing import List, Dict

WHITE, GRAY, BLACK = range(3)
NIL = -1


class DfsVoting:
    def __init__(self, n):
        self.graph: List[List[int]] = []
        self.voted = [False]*n
        for _ in range(n):
            self.graph.append([])

    def vote(self, x, y):
        assert not self.voted[x], f'{x} already voted'
        self.graph[y].append(x)
        self.voted[x] = True

    def count_votes(self):
        n = len(self.graph)
        self.color = [WHITE]*n
        self.pi = [NIL]*n
        self.time = 0
        self.d = [0]*n  # @audit TODO d and f lists may be extra
        self.f = [0]*n
        self.count = [0]*n  # count[x] := x's votes
        self.cycle_arcs = []  # holds back arcs of DFS tree

        for u in range(n):
            if not self.color[u]:
                self._dfs_visit(u)

        self._count_in_cycles()

        return self.count

    def get_winner(self):
        most_votes_id, tied = _is_tied()
        if not tied:
            return most_votes_id

        n = len(self.graph)
        active_voters = n

        def end_with_voter():
            global active_voters
            active_voters -= 1

        tied_data: Dict[int, TiedPersonData] = {}
        max_vote, winner = 0, -1
        ranks = []

        # counting direct votes giving to tied-in-the-first-place (max-tied) people
        for x in range(n):
            # 3rd parameter is called when a voter's rank is exhausted and it's the first time such event is detected
            rank_x = Rank(x, self, end_with_voter, self.count[most_votes_id])
            try:
                # gets next max-tied person in x's ranking and the time its predecessor (can be a non max-tied) in
                # the ranking voted for him
                first_x, vote_time = next(rank_x)  # @todo el next() tiene q pinchar a la par del get_first()

                if first_x not in tied_data:
                    tied_data[first_x] = TiedPersonData(first_x, vote_time)
                else:
                    tied_data[first_x].add_vote(vote_time)

                if tied_data[first_x].votes > max_vote:
                    max_vote = tied_data[first_x].votes
                    winner = first_x
            except StopIteration:
                # @todo asegu'rat q este' pinchan2 bien el descuento, ya sea con el callback o tengas q hacerlo aki'
                pass

            ranks.append(rank_x)

        assert winner != -1

        #  @todo implements a heap of TiedPersonData. Include an idx field in TiedPersonData
        #   denoting its position in the heap
        heap = TiedPersonHeap(tied_data.values())

        while heap.max.votes <= active_voters // 2:  # majority isn't achieved yet
            loser = heap.pop_min()

            # @todo get_first() performs a next() and return None when StopIteration is raised, current otherwise
            loser_first = ranks[loser.id].get_first()
            if loser_first:
                votes_to_sum = loser.votes

                f_first = ranks[loser_first.id].get_first()
                if f_first and f_first.id == loser.id:  # loser's first choice voted for loser
                    votes_to_sum -= 1

                heap.sum_votes(votes_to_sum, loser_first)
            else:
                # @todo see if active_voters must be decreased. end_with_voter() callback must be taken into account.
                # @audit NOTE The callback doesn't seem right. Counting and discounting aren't trivial.
                pass

            Rank.remove(loser)

        return heap.max.id

    def _dfs_visit(self, u):
        self.time += 1
        self.d[u] = self.time
        self.color[u] = GRAY

        for v in self.graph[u]:
            if not self.color[v]:
                self.pi[v] = u
                self._dfs_visit(v)
            
            # it's not an elif 'cause I want it executed when coming out from if above
            if self.color[v] == BLACK:
                self.pi[v] = u  # @todo TODO test parent relationship when this line executes
                self.count[u] += self.count[v] + 1
            elif self.color[v] == GRAY:  # cycle found
                self._notify_cycle(u, v)
        
        self.color[u] = BLACK
        self.time += 1
        self.f[u] = self.time

    def _notify_cycle(self, u, v):
        self.cycle_arcs.append((u, v))

    def _count_in_cycles(self):
        """Count votes for vertices in a cycle. Assigns the maximum count so far to all vertices in the cycle."""
        for u, v in self.cycle_arcs:
            cycle = []
            max_count = self.count[v]

            while u != v:
                cycle.append(u)
                max_count = max(max_count, self.count[u])
                u = self.pi[u]

            cycle.append(v)

            for x in cycle:
                self.count[x] = max_count
