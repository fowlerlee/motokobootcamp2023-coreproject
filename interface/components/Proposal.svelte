<script>
  export let post
</script>

<div class="post-preview">
  <h2>{post[0]}</h2>
  <p>{post[1].principal.toString()}</p>
  <p>Change website text to: {post[1].text}</p>
  <p>
    Yes: {(post[1].vote_for).toString()}, No: {(
      post[1].vote_against).toString()}
  </p>
</div>

<style>
  .post-preview {
    border: 1px solid white;
    border-radius: 10px;
    margin-bottom: 2vmin;
    padding: 2vmin;
  }
  h2 {
    color: white;
  }

  p {
    color: white;
  }
</style>
