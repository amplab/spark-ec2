# Contributing to spark-ec2

Contributions via GitHub pull requests are gladly accepted from their original author. Along with any pull requests, please state that the contribution is your original work and that you license the work to the project under the project's open source license. Whether or not you state this explicitly, by submitting any copyrighted material via pull request, email, or other means you agree to license the material under the project's open source license and warrant that you have the legal authority to do so.

## Which branch to open your patch against

Generally, you want to open PRs against the branch here that corresponds to the latest branch of Spark, unless you are backporting fixes for older versions.

The branches in this repo line up with [the branches in the Apache Spark repo](https://github.com/apache/spark/branches), with the exception of `master`, which this repo doesn't use. So, for example, `branch-1.3` here corresponds to `branch-1.3` in the main Spark repo. If `branch-1.3` is the latest Spark branch, then that's the branch you want to open your PR against here.

If you are backporting fixes for older versions of Spark, note that prior to 1.3.0 there was a [non-obvious branch mapping](https://cwiki.apache.org/confluence/display/SPARK/spark-ec2+AMI+list+and+install+file+version+mappings) between this repo and the main Spark repo.

## Testing your patch

Test your patch by pointing [`spark-ec2`](https://github.com/apache/spark/tree/master/ec2) at your fork of this repo, launching a cluster, and testing your changes. You can tell `spark-ec2` to use your fork of this repo by setting the [`--spark-ec2-git-repo` and `--spark-ec2-git-branch` arguments](https://github.com/apache/spark/blob/e28b6bdbb5c5e4fd62ec0b547b77719c3f7e476e/ec2/spark_ec2.py#L153-L160) at the command line.
