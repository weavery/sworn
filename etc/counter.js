// Generated by Sworn 1.0.0

clarity.requireVersion("0.1");

function getCounter(state) {
  return clarity.ok(state.counter);
}

function increment(state) {
  state.counter = clarity.add(state.counter, 1);
  return {state, result: clarity.ok(state.counter)};
}

function decrement(state) {
  state.counter = clarity.sub(state.counter, 1);
  return {state, result: clarity.ok(state.counter)};
}

export function handle(state, action) {
  const input = action.input;
  if (input.function === 'getCounter') {
    return {result: getCounter(state)};
  }
  if (input.function === 'increment') {
    return increment(state);
  }
  if (input.function === 'decrement') {
    return decrement(state);
  }
  return {state};
}
