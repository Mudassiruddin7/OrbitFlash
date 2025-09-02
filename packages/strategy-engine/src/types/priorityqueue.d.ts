declare module 'priorityqueuejs' {
  export default class PriorityQueue<T> {
    constructor(compareFn?: (a: T, b: T) => number);
    enq(item: T): void;
    deq(): T | undefined;
    peek(): T | undefined;
    size(): number;
  }
}
