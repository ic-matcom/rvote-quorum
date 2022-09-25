from typing import List

WHITE, GRAY, BLACK = range(3)
NIL = -1


class DfsVoting:
    def __init__(self, n):
        self.graph: List[List[int]] = []
        self.voted = [False]*n
        for _ in range(n):
            self.graph.append([])

        self.color = [WHITE]*n
        self.pi = [NIL]*n
        self.time = 0
        self.d = [0]*n  # @audit TODO d and f lists may be extra
        self.f = [0]*n
        self.count = [0]*n  # count[x] := x's votes
        self.cycle_arcs = []  # holds back arcs of DFS tree

    def vote(self, x, y):
        assert not self.voted[x], f'{x} already voted'
        self.graph[y].append(x)
        self.voted[x] = True

    def count_votes(self):
        n = len(self.graph)
        
        for u in range(n):
            if not self.color[u]:
                self._dfs_visit(u)

        self._count_in_cycles()

        return self.count
    
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
