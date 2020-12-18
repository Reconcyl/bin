import random

# Calculate the rate of efficiency decline during this
# time step, given the fraction of businesses that are
# using filters.
def efficiency(f):
    return 1 - (0.03 * (1 - f))

# Calculate the amount of profit a business could produce
# in this time step, given the following information:
# - n: the number of businesses
# - e: what the efficiency rate would be
# - f: whether this business decides to use filters
def profit(params, n, e, f):
    return params["REV"] / n * e - params["OP"] - (params["FIL"] * f)

params = {
    "REV": 150,
    "OP": 11,
    "FIL": 0.1,
}

class State:
    def __init__(self, params):
        self.t = 0
        self.e = 1     # initial efficiency
        self.f = False # whether businesses are currently using filters

        random.seed(params["SEED"])
        # initial value of all businesses
        self.businesses = [random.random() * 100 for _ in range(10)]

        # simulation parameters
        self.params = params

    def step(self):
        self.t += 1

        n = len(self.businesses)
        e = self.e
        f = self.f
        businesses = self.businesses

        # simulate each business's thought process

        #  what would my profit be, if I decided to use the filter?
        p1 = profit(params, n, e*efficiency(1     if f else 1/n), True)

        #  what would my profit be, if I decided not to use the filter?
        p2 = profit(params, n, e*efficiency(1-1/n if f else   0), False)

        # if it would be more efficient to use the filter,
        # all businesses decide to use the filter
        f = p1 > p2

        e *= efficiency(f)

        # the actual profit for each business
        global_profit = profit(params, n, e, f)

        # adjust the businesses' values
        businesses = list(filter(lambda v: v > 0,
                                 (v + global_profit for v in businesses)))

        self.e = e
        self.f = f
        self.businesses = businesses

def gen_params():
    random.seed()
    seed = random.randint(1, 100000)
    return { "REV": rev, "OP": op, "FIL": fil, "SEED": seed }

def count(params=None):
    if params is None:
        params = gen_params()
    state = State(params)
    while state.businesses and not state.f:
        state.step()
    return { "seed": params["SEED"], "steps": state.t, "len": len(state.businesses) }
    
